lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami_id/version"

Gem::Specification.new do |spec|
  spec.name         = "hanami_id"
  spec.version      = HanamiId::VERSION
  spec.authors      = ["Viacheslav Ptsarev"]
  spec.email        = ["leemour@gmail.com"]

  spec.summary      = "Authentication for Hanami framework"
  spec.description  = spec.summary
  spec.homepage     = "https://github.com/leemour/hanami_id"
  spec.license      = "MIT"
  spec.required_ruby_version = "~> 2.2"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
    spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"
  end

  spec.files = Dir[
    "lib/**/*", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE.txt", "README.md"
  ]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bcrypt", "~> 3.1"
  spec.add_dependency "i18n", "~> 1.6"
  spec.add_dependency "warden", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "hanami", "~> 1.3"
  spec.add_development_dependency "hanami-model", "~> 1.3"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
