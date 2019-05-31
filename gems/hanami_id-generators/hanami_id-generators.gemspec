# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami_id-generators/version"

Gem::Specification.new do |spec|
  spec.name         = "hanami_id-generators"
  spec.version      = HanamiId::Generators::VERSION
  spec.authors      = ["Viacheslav Ptsarev"]
  spec.email        = ["leemour@gmail.com"]

  spec.summary      = "Generators for HanamiId"
  spec.description  = <<~DESC
    Generates authentication app with all controller actions, views and
    templates.
  DESC
  spec.homepage     = "https://github.com/leemour/hanami_id/gems/hanami_id-generators"
  spec.license      = "MIT"
  spec.required_ruby_version = "~> 2.3"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
    spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"
  end

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "hanami", "~> 1.3"

  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "pry-byebug", "~> 0.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
