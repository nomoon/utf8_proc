# coding: utf-8
# frozen_string_literal: true
# rubocop:disable BlockLength
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "utf8_proc/version"

Gem::Specification.new do |spec|
  spec.name          = "utf8_proc"
  spec.version       = UTF8Proc::VERSION
  spec.authors       = ["Tim Bellefleur"]
  spec.email         = ["nomoon@phoebus.ca"]

  spec.summary       = "Unicode normalization library using utf8proc"
  spec.homepage      = "https://github.com/nomoon/utf8_proc"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.0"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(bin|test|spec|features)/})
  end
  spec.files += ["vendor/libutf8proc/LICENSE.md",
                 "vendor/libutf8proc/utf8proc.c",
                 "vendor/libutf8proc/utf8proc.h",
                 "vendor/libutf8proc/utf8proc_data.c"]

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "minitest", "~> 5.10"
  spec.add_development_dependency "rubocop", "~> 0.47"
  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "unf"

  unless RUBY_ENGINE == "jruby"
    spec.extensions = ["ext/utf8_proc/extconf.rb"]
    spec.add_development_dependency "rake-compiler", "~> 1.0"
  end
end
