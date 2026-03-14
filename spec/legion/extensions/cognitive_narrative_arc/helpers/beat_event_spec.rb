# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveNarrativeArc::Helpers::BeatEvent do
  let(:beat) { described_class.new(content: 'A key realization', beat_type: :rising_action) }

  describe '#initialize' do
    it 'assigns a uuid beat_id' do
      expect(beat.beat_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores content' do
      expect(beat.content).to eq('A key realization')
    end

    it 'defaults intensity to 0.5' do
      expect(beat.intensity).to eq(0.5)
    end

    it 'clamps intensity to 0..1 range' do
      high = described_class.new(content: 'x', intensity: 5.0)
      low  = described_class.new(content: 'x', intensity: -2.0)
      expect(high.intensity).to eq(1.0)
      expect(low.intensity).to eq(0.0)
    end

    it 'clamps emotional_charge to -1..1 range' do
      positive = described_class.new(content: 'x', emotional_charge: 2.0)
      negative = described_class.new(content: 'x', emotional_charge: -3.0)
      expect(positive.emotional_charge).to eq(1.0)
      expect(negative.emotional_charge).to eq(-1.0)
    end

    it 'defaults to exposition when beat_type is invalid' do
      beat = described_class.new(content: 'x', beat_type: :invalid_type)
      expect(beat.beat_type).to eq(:exposition)
    end

    it 'accepts all valid beat types' do
      Legion::Extensions::CognitiveNarrativeArc::Helpers::Constants::BEAT_TYPES.each do |type|
        b = described_class.new(content: 'x', beat_type: type)
        expect(b.beat_type).to eq(type)
      end
    end

    it 'records created_at timestamp' do
      expect(beat.created_at).to be_a(Time)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = beat.to_h
      expect(h.keys).to include(:beat_id, :content, :intensity, :beat_type, :domain,
                                 :emotional_charge, :created_at)
    end
  end

  describe '#climactic?' do
    it 'returns true for climax beat type' do
      climax = described_class.new(content: 'x', beat_type: :climax)
      expect(climax.climactic?).to be true
    end

    it 'returns true when intensity is at or above climax threshold' do
      intense = described_class.new(content: 'x', intensity: 0.9)
      expect(intense.climactic?).to be true
    end

    it 'returns false for low-intensity non-climax beat' do
      normal = described_class.new(content: 'x', beat_type: :rising_action, intensity: 0.3)
      expect(normal.climactic?).to be false
    end
  end

  describe '#resolving?' do
    it 'returns true for falling_action' do
      b = described_class.new(content: 'x', beat_type: :falling_action)
      expect(b.resolving?).to be true
    end

    it 'returns true for resolution' do
      b = described_class.new(content: 'x', beat_type: :resolution)
      expect(b.resolving?).to be true
    end

    it 'returns true for denouement' do
      b = described_class.new(content: 'x', beat_type: :denouement)
      expect(b.resolving?).to be true
    end

    it 'returns false for rising_action' do
      b = described_class.new(content: 'x', beat_type: :rising_action)
      expect(b.resolving?).to be false
    end
  end
end
