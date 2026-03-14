# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveNarrativeArc::Helpers::ArcEngine do
  let(:engine) { described_class.new }

  def add_beat_to_arc(arc_id, beat_type: :rising_action, intensity: 0.5)
    engine.add_beat(
      arc_id:    arc_id,
      content:   "Beat content for #{beat_type}",
      beat_type: beat_type,
      intensity: intensity
    )
  end

  describe '#create_arc' do
    it 'creates and returns an arc' do
      arc = engine.create_arc(title: 'Test arc')
      expect(arc).to be_a(Legion::Extensions::CognitiveNarrativeArc::Helpers::Arc)
    end

    it 'stores the arc internally' do
      arc = engine.create_arc(title: 'Stored arc')
      expect(engine.get_arc(arc.arc_id)).to eq(arc)
    end

    it 'returns nil when engine is at capacity' do
      stub_const(
        'Legion::Extensions::CognitiveNarrativeArc::Helpers::Constants::MAX_ARCS',
        0
      )
      expect(engine.create_arc(title: 'overflow')).to be_nil
    end
  end

  describe '#add_beat' do
    let(:arc) { engine.create_arc(title: 'Arc for beats') }

    it 'adds a beat successfully' do
      result = add_beat_to_arc(arc.arc_id)
      expect(result[:success]).to be true
      expect(result[:beat_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'returns arc_phase and tension_level in the result' do
      result = add_beat_to_arc(arc.arc_id)
      expect(result[:arc_phase]).to be_a(Symbol)
      expect(result[:tension_level]).to be_a(Float)
    end

    it 'returns failure for unknown arc_id' do
      result = engine.add_beat(arc_id: 'nonexistent', content: 'x')
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:arc_not_found)
    end
  end

  describe '#get_arc' do
    it 'returns nil for unknown arc_id' do
      expect(engine.get_arc('missing')).to be_nil
    end

    it 'returns the arc object for a known id' do
      arc = engine.create_arc(title: 'Known arc')
      expect(engine.get_arc(arc.arc_id)).to eq(arc)
    end
  end

  describe '#active_arcs' do
    it 'returns arcs that are not complete' do
      engine.create_arc(title: 'Active one')
      engine.create_arc(title: 'Active two')
      expect(engine.active_arcs.size).to eq(2)
    end

    it 'excludes completed arcs' do
      arc = engine.create_arc(title: 'Will complete')
      add_beat_to_arc(arc.arc_id, beat_type: :climax, intensity: 0.95)
      add_beat_to_arc(arc.arc_id, beat_type: :resolution)
      expect(engine.active_arcs).not_to include(arc)
    end
  end

  describe '#completed_arcs' do
    it 'returns only completed arcs' do
      engine.create_arc(title: 'Still active')
      arc = engine.create_arc(title: 'Will complete')
      add_beat_to_arc(arc.arc_id, beat_type: :climax, intensity: 0.95)
      add_beat_to_arc(arc.arc_id, beat_type: :resolution)

      completed = engine.completed_arcs
      expect(completed.size).to eq(1)
      expect(completed.first.arc_id).to eq(arc.arc_id)
    end
  end

  describe '#most_dramatic_arc' do
    it 'returns nil when no arcs exist' do
      expect(engine.most_dramatic_arc).to be_nil
    end

    it 'returns the arc with the highest dramatic score' do
      arc_low  = engine.create_arc(title: 'Low drama')
      arc_high = engine.create_arc(title: 'High drama')
      add_beat_to_arc(arc_high.arc_id, beat_type: :climax, intensity: 0.95)
      add_beat_to_arc(arc_high.arc_id, beat_type: :complication, intensity: 0.8)

      expect(engine.most_dramatic_arc.arc_id).to eq(arc_high.arc_id)
      expect(engine.most_dramatic_arc.arc_id).not_to eq(arc_low.arc_id)
    end
  end

  describe '#tension_distribution' do
    it 'returns empty hash when no arcs exist' do
      expect(engine.tension_distribution).to eq({})
    end

    it 'categorizes arcs by tension label' do
      engine.create_arc(title: 'Low tension')
      dist = engine.tension_distribution
      expect(dist).to be_a(Hash)
      expect(dist.values.sum).to eq(1)
    end
  end

  describe '#detect_narrative_patterns' do
    it 'returns empty array with fewer than 2 arcs' do
      engine.create_arc(title: 'Solo arc')
      expect(engine.detect_narrative_patterns).to eq([])
    end

    it 'detects recurring_crisis pattern across arcs' do
      2.times do |i|
        a = engine.create_arc(title: "Crisis arc #{i}")
        add_beat_to_arc(a.arc_id, beat_type: :crisis)
      end
      expect(engine.detect_narrative_patterns).to include(:recurring_crisis)
    end

    it 'detects recurring_climax pattern across arcs' do
      2.times do |i|
        a = engine.create_arc(title: "Climax arc #{i}")
        add_beat_to_arc(a.arc_id, beat_type: :climax, intensity: 0.95)
      end
      expect(engine.detect_narrative_patterns).to include(:recurring_climax)
    end

    it 'detects unresolved_tension when an active arc is at climax level' do
      a = engine.create_arc(title: 'High tension')
      b = engine.create_arc(title: 'Normal')
      50.times { a.tension_rise! }
      expect(engine.detect_narrative_patterns).to include(:unresolved_tension)
      expect(b).to be_a(Legion::Extensions::CognitiveNarrativeArc::Helpers::Arc)
    end

    it 'detects rapid_resolution pattern for arcs with <= 3 beats' do
      arc = engine.create_arc(title: 'Fast resolve 1')
      second = engine.create_arc(title: 'Fast resolve 2')
      add_beat_to_arc(arc.arc_id, beat_type: :climax, intensity: 0.95)
      add_beat_to_arc(arc.arc_id, beat_type: :resolution)
      expect(engine.detect_narrative_patterns).to include(:rapid_resolution)
      expect(second).to be_a(Legion::Extensions::CognitiveNarrativeArc::Helpers::Arc)
    end
  end

  describe '#arc_report' do
    it 'returns a structured report' do
      engine.create_arc(title: 'Report arc')
      report = engine.arc_report
      expect(report[:total_arcs]).to eq(1)
      expect(report[:active]).to eq(1)
      expect(report[:completed]).to eq(0)
      expect(report[:patterns]).to be_an(Array)
      expect(report[:tension_dist]).to be_a(Hash)
    end

    it 'includes most_dramatic in report' do
      engine.create_arc(title: 'Dramatic arc')
      report = engine.arc_report
      expect(report[:most_dramatic]).to be_a(Hash)
      expect(report[:most_dramatic]).to include(:arc_id)
    end
  end
end
