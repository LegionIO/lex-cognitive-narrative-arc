# frozen_string_literal: true

require 'legion/extensions/cognitive_narrative_arc/helpers/constants'
require 'legion/extensions/cognitive_narrative_arc/helpers/beat_event'
require 'legion/extensions/cognitive_narrative_arc/helpers/arc'
require 'legion/extensions/cognitive_narrative_arc/helpers/arc_engine'
require 'legion/extensions/cognitive_narrative_arc/runners/narrative'

module Legion
  module Extensions
    module CognitiveNarrativeArc
      class Client
        include Runners::Narrative

        def initialize(**)
          @arc_engine = Helpers::ArcEngine.new
        end

        private

        attr_reader :arc_engine
      end
    end
  end
end
