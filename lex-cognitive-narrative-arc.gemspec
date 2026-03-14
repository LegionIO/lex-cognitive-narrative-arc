# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_narrative_arc/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-narrative-arc'
  spec.version       = Legion::Extensions::CognitiveNarrativeArc::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Narrative Arc'
  spec.description   = 'Narrative arc detection in cognitive experience for LegionIO'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-narrative-arc'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-narrative-arc'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-narrative-arc'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-narrative-arc'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-narrative-arc/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{\A(?:test|spec|features)/})
  end
  spec.require_paths = ['lib']
end
