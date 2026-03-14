# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveNarrativeArc::Helpers::Arc do
  let(:arc) { described_class.new(title: 'Debugging the anomaly', domain: :technical) }

  let(:beat_rising) do
    Legion::Extensions::CognitiveNarrativeArc::Helpers::BeatEvent.new(
      content: 'First clue found', beat_type: :rising_action, intensity: 0.4
    )
  end

  let(:beat_climax) do
    Legion::Extensions::CognitiveNarrativeArc::Helpers::BeatEvent.new(
      content: 'Root cause identified', beat_type: :climax, intensity: 0.95
    )
  end

  let(:beat_resolution) do
    Legion::Extensions::CognitiveNarrativeArc::Helpers::BeatEvent.new(
      content: 'Fix applied', beat_type: :resolution, intensity: 0.3
    )
  end

  describe '#initialize' do
    it 'assigns a uuid arc_id' do
      expect(arc.arc_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'starts in building phase' do
      expect(arc.arc_phase).to eq(:building)
    end

    it 'starts with default tension' do
      expect(arc.tension_level).to eq(Legion::Extensions::CognitiveNarrativeArc::Helpers::Constants::DEFAULT_TENSION)
    end

    it 'starts with empty beats array' do
      expect(arc.beats).to be_empty
    end
  end

  describe '#add_beat!' do
    it 'adds a beat and returns true' do
      expect(arc.add_beat!(beat_rising)).to be true
      expect(arc.beats.size).to eq(1)
    end

    it 'raises tension on rising_action beats' do
      initial = arc.tension_level
      arc.add_beat!(beat_rising)
      expect(arc.tension_level).to be > initial
    end

    it 'transitions to peak phase on climax beat' do
      arc.add_beat!(beat_climax)
      expect(arc.arc_phase).to eq(:peak)
    end

    it 'transitions to complete phase on resolution beat after climax' do
      arc.add_beat!(beat_climax)
      arc.add_beat!(beat_resolution)
      expect(arc.arc_phase).to eq(:complete)
    end

    it 'returns false when arc is complete' do
      arc.add_beat!(beat_climax)
      arc.add_beat!(beat_resolution)
      expect(arc.add_beat!(beat_rising)).to be false
    end
  end

  describe '#tension_rise!' do
    it 'increases tension by the default rise amount' do
      initial = arc.tension_level
      arc.tension_rise!
      expect(arc.tension_level).to be > initial
    end

    it 'clamps tension to 1.0' do
      50.times { arc.tension_rise! }
      expect(arc.tension_level).to eq(1.0)
    end

    it 'accepts a custom amount' do
      initial = arc.tension_level
      arc.tension_rise!(0.5)
      expect(arc.tension_level).to be_within(0.001).of(initial + 0.5)
    end
  end

  describe '#tension_fall!' do
    it 'decreases tension by the default fall amount' do
      arc.tension_rise!(0.5)
      initial = arc.tension_level
      arc.tension_fall!
      expect(arc.tension_level).to be < initial
    end

    it 'clamps tension to 0.0' do
      50.times { arc.tension_fall! }
      expect(arc.tension_level).to eq(0.0)
    end
  end

  describe '#climaxed?' do
    it 'returns false for a fresh arc' do
      expect(arc.climaxed?).to be false
    end

    it 'returns true when tension is at or above climax threshold' do
      50.times { arc.tension_rise! }
      expect(arc.climaxed?).to be true
    end

    it 'returns true when arc is in peak phase' do
      arc.add_beat!(beat_climax)
      expect(arc.climaxed?).to be true
    end
  end

  describe '#resolved?' do
    it 'returns false before resolution' do
      expect(arc.resolved?).to be false
    end

    it 'returns true after resolution beat' do
      arc.add_beat!(beat_climax)
      arc.add_beat!(beat_resolution)
      expect(arc.resolved?).to be true
    end
  end

  describe '#dramatic_score' do
    it 'returns 0.0 for an empty arc' do
      expect(arc.dramatic_score).to eq(0.0)
    end

    it 'returns a value between 0 and 1' do
      arc.add_beat!(beat_rising)
      arc.add_beat!(beat_climax)
      expect(arc.dramatic_score).to be_between(0.0, 1.0)
    end

    it 'increases after adding a high-intensity beat' do
      arc.add_beat!(beat_rising)
      score_before = arc.dramatic_score
      arc.add_beat!(beat_climax)
      expect(arc.dramatic_score).to be >= score_before
    end
  end

  describe '#to_h' do
    it 'includes all required keys' do
      h = arc.to_h
      expect(h.keys).to include(:arc_id, :title, :domain, :arc_phase, :tension_level,
                                :beat_count, :dramatic_score, :tension_label, :drama_label,
                                :created_at, :resolved_at)
    end

    it 'reflects current beat count' do
      arc.add_beat!(beat_rising)
      expect(arc.to_h[:beat_count]).to eq(1)
    end
  end

  describe '#advance_phase!' do
    it 'returns the current phase' do
      expect(arc.advance_phase!).to eq(:building)
    end

    it 'transitions to peak when tension hits climax threshold' do
      50.times { arc.tension_rise! }
      arc.advance_phase!
      expect(arc.arc_phase).to eq(:peak)
    end
  end
end
