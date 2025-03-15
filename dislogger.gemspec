# frozen_string_literal: true

require_relative "lib/dislogger/version"

Gem::Specification.new do |spec|
  spec.name = "dislogger"
  spec.version = Dislogger::VERSION
  spec.authors = ["Nelson Duarte"]
  spec.email = ["nelson.duartex@gmail.com"]

  spec.summary = "A Ruby on Rails gem for elegant error handling and Discord notifications"
  spec.description = "Automatically capture and notify errors through Discord webhooks while maintaining clean error responses for your API"
  spec.homepage = "https://github.com/nduartex/dislogger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nduartex/dislogger"
  spec.metadata["changelog_uri"] = "https://github.com/nduartex/dislogger/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["{lib}/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "httparty"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
