# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveNarrativeArc::Helpers::Constants do
  describe 'BEAT_TYPES' do
    it 'contains all eight Freytag beat types' do
      expect(described_class::BEAT_TYPES).to include(
        :exposition, :rising_action, :complication, :crisis,
        :climax, :falling_action, :resolution, :denouement
      )
    end

    it 'is frozen' do
      expect(described_class::BEAT_TYPES).to be_frozen
    end
  end

  describe 'ARC_PHASES' do
    it 'contains all four arc phases' do
      expect(described_class::ARC_PHASES).to eq(%i[building peak resolving complete])
    end
  end

  describe 'tension constants' do
    it 'defines a default tension below climax threshold' do
      expect(described_class::DEFAULT_TENSION).to be < described_class::CLIMAX_THRESHOLD
    end

    it 'defines resolution threshold below default tension' do
      expect(described_class::RESOLUTION_THRESHOLD).to be < described_class::DEFAULT_TENSION
    end

    it 'defines TENSION_RISE greater than TENSION_FALL' do
      expect(described_class::TENSION_RISE).to be > described_class::TENSION_FALL
    end
  end

  describe '.label_for' do
    it 'returns :calm for low tension values' do
      expect(described_class.label_for(described_class::TENSION_LABELS, 0.1)).to eq(:calm)
    end

    it 'returns :critical for high tension values' do
      expect(described_class.label_for(described_class::TENSION_LABELS, 0.9)).to eq(:critical)
    end

    it 'returns :developing for mid-range values' do
      expect(described_class.label_for(described_class::TENSION_LABELS, 0.35)).to eq(:developing)
    end

    it 'returns :tense for values in the tense range' do
      expect(described_class.label_for(described_class::TENSION_LABELS, 0.65)).to eq(:tense)
    end

    it 'returns :mundane for low drama score' do
      expect(described_class.label_for(described_class::DRAMA_LABELS, 0.1)).to eq(:mundane)
    end

    it 'returns :gripping for high drama score' do
      expect(described_class.label_for(described_class::DRAMA_LABELS, 0.9)).to eq(:gripping)
    end

    it 'falls back to last label when value is 1.0' do
      result = described_class.label_for(described_class::TENSION_LABELS, 1.0)
      expect(result).to eq(:critical)
    end
  end

  describe 'PHASE_LABELS' do
    it 'has a description for each arc phase' do
      described_class::ARC_PHASES.each do |phase|
        expect(described_class::PHASE_LABELS[phase]).to be_a(String)
      end
    end
  end
end
