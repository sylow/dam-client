# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'dam-client'
  spec.version       = '0.1.0'
  spec.authors       = ['Razor USA']
  spec.email         = ['dev@razorusa.com']

  spec.summary       = 'Universal DAM (Digital Asset Management) client supporting multiple providers'
  spec.description   = 'A unified Ruby client for Digital Asset Management systems. Currently supports Webdam and Bynder with a common interface for switching between providers.'
  spec.homepage      = 'https://github.com/razorusa/dam-client'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE', 'CHANGELOG.md']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'faraday', '>= 1.0', '< 3.0'
  spec.add_dependency 'faraday_middleware', '~> 1.0'
  spec.add_dependency 'hashie', '~> 5.0'

  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'vcr', '~> 6.0'
end
