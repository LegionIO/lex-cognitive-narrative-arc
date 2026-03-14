# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveNarrativeArc
      module Helpers
        class ArcEngine
          attr_reader :arcs

          def initialize
            @arcs = {}
          end

          def create_arc(title:, domain: :general, initial_tension: Constants::DEFAULT_TENSION)
            return nil if @arcs.size >= Constants::MAX_ARCS

            arc = Arc.new(title: title, domain: domain, initial_tension: initial_tension)
            @arcs[arc.arc_id] = arc
            arc
          end

          def add_beat(arc_id:, content:, intensity: 0.5, beat_type: :rising_action,
                       domain: :general, emotional_charge: 0.0)
            arc = @arcs[arc_id]
            return { success: false, reason: :arc_not_found } unless arc

            beat = BeatEvent.new(
              content:          content,
              intensity:        intensity,
              beat_type:        beat_type,
              domain:           domain,
              emotional_charge: emotional_charge
            )

            added = arc.add_beat!(beat)
            return { success: false, reason: :arc_full_or_complete } unless added

            { success: true, beat_id: beat.beat_id, arc_phase: arc.arc_phase,
              tension_level: arc.tension_level }
          end

          def get_arc(arc_id)
            @arcs[arc_id]
          end

          def active_arcs
            @arcs.values.reject(&:complete?)
          end

          def completed_arcs
            @arcs.values.select(&:complete?)
          end

          def most_dramatic_arc
            return nil if @arcs.empty?

            @arcs.values.max_by(&:dramatic_score)
          end

          def tension_distribution
            return {} if @arcs.empty?

            counts = Hash.new(0)
            @arcs.values.each do |arc|
              label = arc.tension_label
              counts[label] += 1
            end
            counts
          end

          def detect_narrative_patterns
            return [] if @arcs.size < 2

            patterns = []
            patterns << :recurring_crisis if recurring_beat_pattern?(:crisis)
            patterns << :recurring_climax if recurring_beat_pattern?(:climax)
            patterns << :unresolved_tension if unresolved_high_tension?
            patterns << :rapid_resolution if rapid_resolution_pattern?
            patterns
          end

          def arc_report
            {
              total_arcs:     @arcs.size,
              active:         active_arcs.size,
              completed:      completed_arcs.size,
              patterns:       detect_narrative_patterns,
              tension_dist:   tension_distribution,
              most_dramatic:  most_dramatic_arc&.to_h
            }
          end

          private

          def recurring_beat_pattern?(beat_type)
            arc_with_beat_type_count = @arcs.values.count do |arc|
              arc.beats.any? { |b| b.beat_type == beat_type }
            end
            arc_with_beat_type_count >= 2
          end

          def unresolved_high_tension?
            active_arcs.any? { |arc| arc.tension_level >= Constants::CLIMAX_THRESHOLD }
          end

          def rapid_resolution_pattern?
            @arcs.values.any? do |arc|
              arc.complete? && arc.beats.size <= 3
            end
          end
        end
      end
    end
  end
end
