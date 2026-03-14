# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveNarrativeArc
      module Helpers
        class Arc
          attr_reader :arc_id, :title, :domain, :beats, :arc_phase, :tension_level,
                      :created_at, :resolved_at

          def initialize(title:, domain: :general, initial_tension: Constants::DEFAULT_TENSION)
            @arc_id       = SecureRandom.uuid
            @title        = title
            @domain       = domain
            @beats        = []
            @arc_phase    = :building
            @tension_level = initial_tension.clamp(0.0, 1.0)
            @created_at   = Time.now.utc
            @resolved_at  = nil
          end

          def add_beat!(beat)
            return false if @beats.size >= Constants::MAX_BEATS_PER_ARC
            return false if complete?

            @beats << beat
            adjust_tension_for_beat(beat)
            advance_phase!
            true
          end

          def advance_phase!
            new_phase = detect_phase
            @arc_phase = new_phase if new_phase != @arc_phase
            @resolved_at = Time.now.utc if @arc_phase == :complete
            @arc_phase
          end

          def tension_rise!(amount = Constants::TENSION_RISE)
            @tension_level = (@tension_level + amount).round(10).clamp(0.0, 1.0)
          end

          def tension_fall!(amount = Constants::TENSION_FALL)
            @tension_level = (@tension_level - amount).round(10).clamp(0.0, 1.0)
          end

          def climaxed?
            @tension_level >= Constants::CLIMAX_THRESHOLD || @arc_phase == :peak
          end

          def resolved?
            @arc_phase == :complete
          end

          def complete?
            @arc_phase == :complete
          end

          def dramatic_score
            return 0.0 if @beats.empty?

            tension_contrib   = @tension_level * 0.4
            beat_count_contrib = [@beats.size.to_f / Constants::MAX_BEATS_PER_ARC, 1.0].min * 0.3
            intensity_contrib = average_beat_intensity * 0.3
            (tension_contrib + beat_count_contrib + intensity_contrib).round(10)
          end

          def tension_label
            Constants.label_for(Constants::TENSION_LABELS, @tension_level)
          end

          def drama_label
            Constants.label_for(Constants::DRAMA_LABELS, dramatic_score)
          end

          def to_h
            {
              arc_id:        @arc_id,
              title:         @title,
              domain:        @domain,
              arc_phase:     @arc_phase,
              tension_level: @tension_level,
              beat_count:    @beats.size,
              dramatic_score: dramatic_score,
              tension_label:  tension_label,
              drama_label:    drama_label,
              created_at:    @created_at,
              resolved_at:   @resolved_at
            }
          end

          private

          def average_beat_intensity
            return 0.0 if @beats.empty?

            @beats.sum(&:intensity) / @beats.size.to_f
          end

          def adjust_tension_for_beat(beat)
            case beat.beat_type
            when :rising_action, :complication, :crisis
              tension_rise!(beat.intensity * Constants::TENSION_RISE)
            when :climax
              @tension_level = [@tension_level, Constants::CLIMAX_THRESHOLD].max.clamp(0.0, 1.0)
            when :falling_action, :resolution, :denouement
              tension_fall!(beat.intensity * Constants::TENSION_FALL)
            end
          end

          def detect_phase
            return :complete if has_resolution_beat?
            return :resolving if has_climax_beat? && @tension_level < Constants::CLIMAX_THRESHOLD
            return :peak if @tension_level >= Constants::CLIMAX_THRESHOLD
            return :building if @tension_level < Constants::CLIMAX_THRESHOLD

            @arc_phase
          end

          def has_climax_beat?
            @beats.any?(&:climactic?)
          end

          def has_resolution_beat?
            @beats.any? { |b| b.beat_type == :resolution || b.beat_type == :denouement }
          end
        end
      end
    end
  end
end
