# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jra_info/version'

Gem::Specification.new do |spec|
  spec.name          = "jra_info"
  spec.version       = JraInfo::VERSION
  spec.authors       = ["pot8os"]
  spec.email         = ["mygithub@pot8os.net"]
  spec.summary       = %q{command line interface to view horse entries and odds in JRA}
  spec.description   = %q{TBD}
  spec.homepage      = "https://github.com/pot8os/jra_info"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "nokogiri"
end
