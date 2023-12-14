# frozen_string_literal: true

require_relative "lib/mosquito/version"

Gem::Specification.new do |spec|
  spec.name          = "mosquito-scrape"
  spec.version       = Mosquito::VERSION
  spec.authors       = ["Christopher Guess"]
  spec.email         = ["cguess@gmail.com"]

  spec.summary       = "A gem to scrape a Nitter instance for Twitter data"
  # spec.description   = "TODO: Write a longer description or delete this line."
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Prod dependencies
  spec.add_dependency "typhoeus", "~> 1.4"
  spec.add_dependency "nokogiri", "~> 1.15.5"
  spec.add_dependency "capybara", "~> 3.39"
  spec.add_dependency "dotenv", "~> 2.8"
  spec.add_dependency "oj", "~> 3.16"
  spec.add_dependency "fileutils", "~> 1.7"
  spec.add_dependency "logger", "~> 1.6"
  spec.add_dependency "securerandom", "~> 0.3"
  spec.add_dependency "selenium-webdriver", "~> 4"
  spec.add_dependency "open-uri", "~> 0.4"
  spec.add_dependency "activesupport", "~> 7.0.8"
  spec.add_dependency "rack", "~> 2"

  # Dev dependencies
  spec.add_development_dependency "byebug", "~> 11.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-rails", "~> 2.0"
  spec.add_development_dependency "rubocop-rails_config", "~> 1.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.0"
  spec.add_development_dependency "dotenv", "~> 2.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
