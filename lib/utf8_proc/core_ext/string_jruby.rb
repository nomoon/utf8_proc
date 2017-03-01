# frozen_string_literal: true
# rubocop:disable MethodName

# This file should only be required within JRuby

require "java"
require "utf8_proc"

module UTF8Proc
  module JRuby
    # Module containing JRuby core extension methods for the {::String} class.
    module StringExtension
      # @see UTF8Proc::StringExtension#NFC
      def NFC
        ::UTF8Proc.NFC(self)
      end

      # @see UTF8Proc::StringExtension#NFD
      def NFD
        ::UTF8Proc.NFD(self)
      end

      # @see UTF8Proc::StringExtension#NFKC
      def NFKC
        ::UTF8Proc.NFKC(self)
      end

      # @see UTF8Proc::StringExtension#NFKD
      def NFKD
        ::UTF8Proc.NFKD(self)
      end

      # @see UTF8Proc::StringExtension#NFKC_CF
      def NFKC_CF
        ::UTF8Proc.NFKC_CF(self)
      end

      # @see UTF8Proc::StringExtension#normalize
      def normalize(form = :nfc)
        ::UTF8Proc.normalize(self, form)
      end
    end
  end
end

String.include(UTF8Proc::JRuby::StringExtension)
