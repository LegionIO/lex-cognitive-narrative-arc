# frozen_string_literal: true

require 'legion/extensions/cognitive_narrative_arc/client'

RSpec.describe Legion::Extensions::CognitiveNarrativeArc::Runners::Narrative do
  let(:client) { Legion::Extensions::CognitiveNarrativeArc::Client.new }
  let(:engine) { Legion::Extensions::CognitiveNarrativeArc::Helpers::ArcEngine.new }

  describe '#create_arc' do
    it 'creates an arc and returns arc_id' do
      result = client.create_arc(title: 'Debugging mystery')
      expect(result[:success]).to be true
      expect(result[:arc_id]).to match(/\A[0-9a-f-]{36}\z/)
      expect(result[:arc_phase]).to eq(:building)
    end

    it 'stores arc in the engine' do
      result = client.create_arc(title: 'Stored arc')
      arcs = client.active_arcs
      ids = arcs[:arcs].map { |a| a[:arc_id] }
      expect(ids).to include(result[:arc_id])
    end

    it 'accepts custom initial tension' do
      result = client.create_arc(title: 'Tense start', initial_tension: 0.6)
      expect(result[:tension_level]).to eq(0.6)
    end

    it 'accepts an injected engine' do
      result = client.create_arc(title: 'Injected', engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns failure when engine is at capacity' do
      stub_const(
        'Legion::Extensions::CognitiveNarrativeArc::Helpers::Constants::MAX_ARCS',
        0
      )
      result = client.create_arc(title: 'Overflow')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:engine_at_capacity)
    end
  end

  describe '#add_beat' do
    let(:arc_id) { client.create_arc(title: 'Beat test arc')[:arc_id] }

    it 'adds a beat and returns beat_id' do
      result = client.add_beat(arc_id: arc_id, content: 'Something happened', beat_type: :rising_action)
      expect(result[:success]).to be true
      expect(result[:beat_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'includes dramatic_score in result' do
      result = client.add_beat(arc_id: arc_id, content: 'Escalation', beat_type: :complication, intensity: 0.7)
      expect(result[:dramatic_score]).to be_a(Float)
    end

    it 'returns failure for unknown arc' do
      result = client.add_beat(arc_id: 'bad-id', content: 'x')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:arc_not_found)
    end

    it 'transitions arc phase as beats accumulate' do
      client.add_beat(arc_id: arc_id, content: 'Climax!', beat_type: :climax, intensity: 0.95)
      result = client.add_beat(arc_id: arc_id, content: 'Resolution', beat_type: :resolution)
      expect(result[:arc_phase]).to eq(:complete)
    end

    it 'accepts an injected engine' do
      injected_arc_id = client.create_arc(title: 'Injected arc', engine: engine)[:arc_id]
      result = client.add_beat(arc_id: injected_arc_id, content: 'x', engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '#get_arc' do
    it 'returns found arc with beats' do
      arc_id = client.create_arc(title: 'Get test')[:arc_id]
      client.add_beat(arc_id: arc_id, content: 'A beat')
      result = client.get_arc(arc_id: arc_id)
      expect(result[:found]).to be true
      expect(result[:arc]).to include(:arc_id, :title)
      expect(result[:beats].size).to eq(1)
    end

    it 'returns not found for missing arc' do
      result = client.get_arc(arc_id: 'nonexistent')
      expect(result[:found]).to be false
    end
  end

  describe '#active_arcs' do
    it 'returns all non-complete arcs' do
      client.create_arc(title: 'Arc A')
      client.create_arc(title: 'Arc B')
      result = client.active_arcs
      expect(result[:count]).to eq(2)
      expect(result[:arcs].size).to eq(2)
    end
  end

  describe '#completed_arcs' do
    it 'returns arcs that have been resolved' do
      arc_id = client.create_arc(title: 'Complete me')[:arc_id]
      client.add_beat(arc_id: arc_id, content: 'Climax', beat_type: :climax, intensity: 0.95)
      client.add_beat(arc_id: arc_id, content: 'Done', beat_type: :resolution)

      result = client.completed_arcs
      expect(result[:count]).to eq(1)
    end
  end

  describe '#most_dramatic_arc' do
    it 'returns not found when no arcs exist' do
      result = client.most_dramatic_arc
      expect(result[:found]).to be false
    end

    it 'returns the arc with the highest dramatic score' do
      arc_a = client.create_arc(title: 'Boring')[:arc_id]
      arc_b = client.create_arc(title: 'Gripping')[:arc_id]
      client.add_beat(arc_id: arc_b, content: 'Explosion', beat_type: :climax, intensity: 0.99)
      client.add_beat(arc_id: arc_b, content: 'Fallout', beat_type: :complication, intensity: 0.85)

      result = client.most_dramatic_arc
      expect(result[:found]).to be true
      expect(result[:arc][:arc_id]).to eq(arc_b)
      expect(result[:arc][:arc_id]).not_to eq(arc_a)
    end
  end

  describe '#arc_report' do
    it 'returns a complete report structure' do
      client.create_arc(title: 'Report subject')
      result = client.arc_report
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_arcs, :active, :completed, :patterns, :tension_dist)
    end
  end
end
