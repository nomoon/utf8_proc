# frozen_string_literal: true

require "utf8_proc"

class String
  if RUBY_ENGINE == "jruby"
    require "utf8_proc/core_ext/string_jruby"
  else
    include ::UTF8Proc::StringExtension
  end
end
