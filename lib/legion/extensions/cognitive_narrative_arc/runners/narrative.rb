# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveNarrativeArc
      module Runners
        module Narrative
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_arc(title:, domain: :general, initial_tension: Helpers::Constants::DEFAULT_TENSION,
                         engine: nil, **)
            eng = engine || arc_engine
            arc = eng.create_arc(title: title, domain: domain, initial_tension: initial_tension)

            unless arc
              Legion::Logging.warn "[narrative_arc] create_arc failed: engine at capacity (#{Helpers::Constants::MAX_ARCS})"
              return { success: false, reason: :engine_at_capacity }
            end

            Legion::Logging.debug "[narrative_arc] arc created: #{arc.arc_id[0..7]} title=#{title} domain=#{domain}"
            { success: true, arc_id: arc.arc_id, title: arc.title, arc_phase: arc.arc_phase,
              tension_level: arc.tension_level }
          end

          def add_beat(arc_id:, content:, intensity: 0.5, beat_type: :rising_action,
                       domain: :general, emotional_charge: 0.0, engine: nil, **)
            eng = engine || arc_engine
            result = eng.add_beat(
              arc_id:           arc_id,
              content:          content,
              intensity:        intensity,
              beat_type:        beat_type,
              domain:           domain,
              emotional_charge: emotional_charge
            )

            if result[:success]
              arc = eng.get_arc(arc_id)
              Legion::Logging.debug "[narrative_arc] beat added: arc=#{arc_id[0..7]} type=#{beat_type} " \
                                    "phase=#{result[:arc_phase]} tension=#{result[:tension_level].round(2)}"
              result[:dramatic_score] = arc.dramatic_score if arc
            else
              Legion::Logging.debug "[narrative_arc] add_beat failed: #{result[:reason]} arc=#{arc_id[0..7]}"
            end

            result
          end

          def get_arc(arc_id:, engine: nil, **)
            eng = engine || arc_engine
            arc = eng.get_arc(arc_id)
            return { found: false, arc_id: arc_id } unless arc

            { found: true, arc: arc.to_h, beats: arc.beats.map(&:to_h) }
          end

          def active_arcs(engine: nil, **)
            eng = engine || arc_engine
            arcs = eng.active_arcs
            Legion::Logging.debug "[narrative_arc] active arcs count=#{arcs.size}"
            { arcs: arcs.map(&:to_h), count: arcs.size }
          end

          def completed_arcs(engine: nil, **)
            eng = engine || arc_engine
            arcs = eng.completed_arcs
            Legion::Logging.debug "[narrative_arc] completed arcs count=#{arcs.size}"
            { arcs: arcs.map(&:to_h), count: arcs.size }
          end

          def most_dramatic_arc(engine: nil, **)
            eng = engine || arc_engine
            arc = eng.most_dramatic_arc
            return { found: false } unless arc

            Legion::Logging.debug "[narrative_arc] most dramatic: #{arc.arc_id[0..7]} score=#{arc.dramatic_score.round(2)}"
            { found: true, arc: arc.to_h }
          end

          def arc_report(engine: nil, **)
            eng = engine || arc_engine
            report = eng.arc_report
            Legion::Logging.debug "[narrative_arc] arc_report total=#{report[:total_arcs]} patterns=#{report[:patterns].inspect}"
            { success: true, report: report }
          end

          private

          def arc_engine
            @arc_engine ||= Helpers::ArcEngine.new
          end
        end
      end
    end
  end
end
