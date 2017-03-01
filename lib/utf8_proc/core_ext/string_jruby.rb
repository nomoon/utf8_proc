# frozen_string_literal: true
# rubocop:disable MethodName

# This file should only be required within JRuby

require "java"
require "utf8_proc"

module UTF8Proc
  module JRuby
    # Module containing JRuby core extension methods for the {::String} class.
    #
    # You can activate this by using:
    #   require "utf8_proc/core_ext/string"
    #
    # It will load either C or Java extensions, depending on your Ruby version.
    module StringExtension
      # @see UTF8Proc::StringExtension#NFC
      def NFC
        ::UTF8Proc.NFC(self)
      end
      alias nfc NFC

      # @see UTF8Proc::StringExtension#NFD
      def NFD
        ::UTF8Proc.NFD(self)
      end
      alias nfd NFD

      # @see UTF8Proc::StringExtension#NFKC
      def NFKC
        ::UTF8Proc.NFKC(self)
      end
      alias nfkc NFKC

      # @see UTF8Proc::StringExtension#NFKD
      def NFKD
        ::UTF8Proc.NFKD(self)
      end
      alias nfkd NFKD

      # @see UTF8Proc::StringExtension#NFKC_CF
      def NFKC_CF
        ::UTF8Proc.NFKC_CF(self)
      end
      alias nfkc_cf NFKC_CF

      # @see UTF8Proc::StringExtension#normalize
      def normalize(form = :nfc)
        ::UTF8Proc.normalize(self, form)
      end
    end
  end
end

String.send(:include, ::UTF8Proc::JRuby::StringExtension)
