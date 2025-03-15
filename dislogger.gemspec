# frozen_string_literal: true

require_relative "lib/dislogger/version"

Gem::Specification.new do |spec|
  spec.name = "dislogger"
  spec.version = Dislogger::VERSION
  spec.authors = ["Nelson"]
  spec.email = ["nelson.duartex@gmail.com"]

  spec.summary = "A Rails gem for standardized error handling with Discord notifications"
  spec.description = "DisLogger provides a robust error handling system for Rails applications with automatic Discord notifications and standardized JSON responses"
  spec.homepage = "https://github.com/nelsonduarte/dislogger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nelsonduarte/dislogger"
  spec.metadata["changelog_uri"] = "https://github.com/nelsonduarte/dislogger/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "httparty", "~> 0.21.0"
  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "actionpack", ">= 6.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rspec", "~> 2.20"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "activerecord", ">= 6.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
