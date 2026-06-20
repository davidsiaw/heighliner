# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heighliner/version'

Gem::Specification.new do |spec|
  spec.name          = 'heighliner'
  spec.version       = Heighliner::VERSION
  spec.authors       = ['David Siaw']
  spec.email         = ['874280+davidsiaw@users.noreply.github.com']

  spec.summary = spec.description = 'Docker Application Simplification Tool'
  spec.homepage      = 'https://github.com/davidsiaw/heighliner'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.5.8'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = Dir['LICENSE.md', 'README.md', 'lib/**/*', 'exe/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'optimist'

  spec.add_development_dependency 'aruba', '~> 0.14.6'
  spec.add_development_dependency 'aruba-rspec'
  spec.add_development_dependency 'factory_bot', '~> 4.0'
  spec.add_development_dependency 'observer'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pstore'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
