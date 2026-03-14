# frozen_string_literal: true

require 'legion/extensions/cognitive_narrative_arc/version'
require 'legion/extensions/cognitive_narrative_arc/helpers/constants'
require 'legion/extensions/cognitive_narrative_arc/helpers/beat_event'
require 'legion/extensions/cognitive_narrative_arc/helpers/arc'
require 'legion/extensions/cognitive_narrative_arc/helpers/arc_engine'
require 'legion/extensions/cognitive_narrative_arc/runners/narrative'

module Legion
  module Extensions
    module CognitiveNarrativeArc
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
