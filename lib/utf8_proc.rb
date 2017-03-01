# frozen_string_literal: true
require "utf8_proc/version"
require "utf8_proc/benchmark"

# {include:file:./README.md}
module UTF8Proc
  if RUBY_ENGINE == "jruby"
    require "utf8_proc/jruby"
    include JRuby
  else
    require "utf8_proc/utf8_proc"
  end

  # Add lowercase name aliases for normalization methods
  class << self
    alias nfc NFC
    alias nfd NFD
    alias nfkc NFKC
    alias nfkd NFKD
    alias nfkc_cf NFKC_CF
  end
end
