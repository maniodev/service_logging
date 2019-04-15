lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "service_logging/version"

Gem::Specification.new do |spec|
  spec.name          = "service_logging"
  spec.version       = ServiceLogging::VERSION
  spec.authors       = ["Savedo Tech Team"]
  spec.email         = ["it@savedo.de"]

  spec.summary       = "Common logging setup for Rails applications"
  spec.description   = "Based on lograge, includes request parsing and filtering of sensitive information"
  spec.homepage      = "https://github.com/Savedo/service_logging"
  spec.license       = "MIT"

  spec.files = Dir["CHANGELOG.md", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "service_logging.gemspec", "lib/**/*"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r(^bin/)) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r(^(test|spec|features)/))
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16", ">= 1.16.0"
  spec.add_development_dependency "rake", "~> 12.3", ">= 12.3.0"
  spec.add_development_dependency "rspec", "~> 3.7", ">= 3.7.0"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.3", ">= 0.3.0"
  spec.add_development_dependency "rubocop", "~> 0.54", ">= 0.54.0"

  spec.add_runtime_dependency "activesupport", ">= 4.2.10"
  spec.add_runtime_dependency "kiev", "~> 3.0"
end
