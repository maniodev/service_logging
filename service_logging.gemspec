# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "lograge"
  spec.add_runtime_dependency "logstash-event"
  spec.add_runtime_dependency "jsonpath"
end
