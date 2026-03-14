# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveNarrativeArc
      module Helpers
        module Constants
          MAX_ARCS           = 100
          MAX_BEATS_PER_ARC  = 50
          DEFAULT_TENSION    = 0.3
          TENSION_RISE       = 0.1
          TENSION_FALL       = 0.08
          CLIMAX_THRESHOLD   = 0.8
          RESOLUTION_THRESHOLD = 0.2

          BEAT_TYPES = %i[
            exposition
            rising_action
            complication
            crisis
            climax
            falling_action
            resolution
            denouement
          ].freeze

          ARC_PHASES = %i[building peak resolving complete].freeze

          TENSION_LABELS = {
            (0.0..0.2)  => :calm,
            (0.2..0.5)  => :developing,
            (0.5..0.8)  => :tense,
            (0.8..1.0)  => :critical
          }.freeze

          DRAMA_LABELS = {
            (0.0..0.25) => :mundane,
            (0.25..0.5) => :engaging,
            (0.5..0.75) => :compelling,
            (0.75..1.0) => :gripping
          }.freeze

          PHASE_LABELS = {
            building:  'Rising action building toward climax',
            peak:      'At or near peak tension — climax active',
            resolving: 'Falling action moving toward resolution',
            complete:  'Arc resolved and closed'
          }.freeze

          module_function

          def label_for(labels_hash, value)
            labels_hash.each do |range, label|
              return label if range.cover?(value)
            end
            labels_hash.values.last
          end
        end
      end
    end
  end
end
