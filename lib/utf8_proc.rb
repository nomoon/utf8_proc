# frozen_string_literal: true
require "utf8_proc/version"
require "utf8_proc/benchmark"

module UTF8Proc
  if RUBY_ENGINE == "jruby"
    require "utf8_proc/jruby"
    include JRuby
  else
    require "utf8_proc/utf8_proc"
  end
end
