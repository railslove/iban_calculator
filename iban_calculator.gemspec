# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iban_calculator/version'

Gem::Specification.new do |spec|
  spec.name          = "iban_calculator"
  spec.version       = IbanCalculator::VERSION
  spec.authors       = ["Maximilian Schulz"]
  spec.email         = ["m.schulz@kulturfluss.de"]
  spec.summary       = %q{Calculate IBAN and BIC for countries of Single European Payments Area (SEPA).}
  spec.description   = %q{At the moment the gem is just a wrapper for the ibanrechner.de API.}
  spec.homepage      = "https://github.com/railslove/iban_calculator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
