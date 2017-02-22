# frozen_string_literal: true
# rubocop:disable MethodName

# This file should only be required within JRuby

require "java"

module UTF8Proc
  module JRuby
    LIBRARY_VERSION = "Java #{ENV_JAVA['java.version']}".freeze

    JTNORM = java.text.Normalizer
    private_constant :JTNORM

    def self.included(receiver)
      receiver.extend(ClassMethods)
    end

    module ClassMethods
      def NFC(string)
        JTNORM.normalize(string, JTNORM::Form::NFC)
      end

      def NFD(string)
        JTNORM.normalize(string, JTNORM::Form::NFD)
      end

      def NFKC(string)
        JTNORM.normalize(string, JTNORM::Form::NFKC)
      end

      def NFKD(string)
        JTNORM.normalize(string, JTNORM::Form::NFKD)
      end

      def NFKC_CF(string)
        NFKC(string).to_java(:string).toLowerCase
      end

      def normalize(string, form = :nfc)
        case form
        when :nfc
          NFC(string)
        when :nfd
          NFD(string)
        when :nfkc
          NFKC(string)
        when :nfkd
          NFKD(string)
        when :nfkc_cf
          NFKC_CF(string)
        else
          raise ArgumentError, "Second argument must be one of [:nfc (default)," \
                               " :nfd, :nfkc, :nfkd, :nfkc_cf]"
        end
      end
    end
  end
end
