# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "utf8_proc/version"

Gem::Specification.new do |spec|
  spec.name          = "utf8_proc"
  spec.version       = UTF8Proc::VERSION
  spec.authors       = ["Tim Bellefleur"]
  spec.email         = ["nomoon@phoebus.ca"]

  spec.summary       = "Ruby Unicode library using utf8proc"
  spec.homepage      = "https://github.com/nomoon/utf8_proc"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/utf8_proc/extconf.rb"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake-compiler", "~> 1.0"
  spec.add_development_dependency "minitest", "~> 5.10"
  spec.add_development_dependency "minitest-assert_errors"
end
