# frozen_string_literal: true
require "utf8_proc/version"

module UTF8Proc
  if defined?(JRUBY_VERSION)
    require "utf8_proc/jruby"
    include JRuby
  else
    require "utf8_proc/utf8_proc"
  end
end
