# frozen_string_literal: true

require "utf8_proc"

module UTF8Proc
  # Module containing C core extension methods for the {::String} class.
  #
  # You can activate this by using:
  #   require "utf8_proc/core_ext/string"
  #
  # It will load either C or Java extensions, depending on your Ruby version.
  module StringExtension
    if RUBY_ENGINE == "jruby"
      require "utf8_proc/core_ext/string_jruby"
    else
      alias nfc NFC
      alias nfd NFD
      alias nfkc NFKC
      alias nfkd NFKD
      alias nfkc_cf NFKC_CF
      String.send(:include, ::UTF8Proc::StringExtension)
    end
  end
end
