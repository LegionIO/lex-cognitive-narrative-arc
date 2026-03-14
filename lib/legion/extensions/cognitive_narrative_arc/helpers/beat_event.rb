# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveNarrativeArc
      module Helpers
        class BeatEvent
          attr_reader :beat_id, :content, :intensity, :beat_type, :domain,
                      :emotional_charge, :created_at

          def initialize(content:, intensity: 0.5, beat_type: :rising_action,
                         domain: :general, emotional_charge: 0.0)
            @beat_id        = SecureRandom.uuid
            @content        = content
            @intensity      = intensity.clamp(0.0, 1.0)
            @beat_type      = validate_beat_type(beat_type)
            @domain         = domain
            @emotional_charge = emotional_charge.clamp(-1.0, 1.0)
            @created_at     = Time.now.utc
          end

          def to_h
            {
              beat_id:         @beat_id,
              content:         @content,
              intensity:       @intensity,
              beat_type:       @beat_type,
              domain:          @domain,
              emotional_charge: @emotional_charge,
              created_at:      @created_at
            }
          end

          def climactic?
            @beat_type == :climax || @intensity >= Constants::CLIMAX_THRESHOLD
          end

          def resolving?
            %i[falling_action resolution denouement].include?(@beat_type)
          end

          private

          def validate_beat_type(type)
            return type if Constants::BEAT_TYPES.include?(type)

            Constants::BEAT_TYPES.first
          end
        end
      end
    end
  end
end
