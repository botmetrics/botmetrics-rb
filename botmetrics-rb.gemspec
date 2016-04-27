# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'botmetrics/version'

Gem::Specification.new do |spec|
  spec.name          = "botmetrics-rb"
  spec.version       = Botmetrics::Rb::VERSION
  spec.authors       = ["arunthampi"]
  spec.email         = ["arun@getbotmetrics.com"]

  spec.summary       = %q{botmetrics-rb is a Ruby Client for https://getbotmetrics.com - a service that lets you collect & analyze metrics for your bot"}
  spec.description   = %q{botmetrics-rb is a Ruby Client for https://getbotmetrics.com - a service that lets you collect & analyze metrics for your bot"}
  spec.homepage      = "https://www.getbotmetrics.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_dependency "json",         "~> 1.8.3"
  spec.add_dependency "excon",        "~> 0.49.0"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
