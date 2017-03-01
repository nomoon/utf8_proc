# frozen_string_literal: true
# rubocop:disable MethodName

# This file should only be required within JRuby

require "java"

module UTF8Proc
  # JRuby normalization module.
  #
  # This module will load automatically depending on your Ruby version.
  module JRuby
    # Displays your version of the Java VM
    LIBRARY_VERSION = "Java #{ENV_JAVA['java.version']}".freeze

    JTNORM = java.text.Normalizer
    private_constant :JTNORM

    # @!visibility private
    def self.included(receiver)
      receiver.extend(ClassMethods)
    end

    # Methods added to the {::UTF8Proc} module in JRuby (instead of the C ones)
    module ClassMethods
      # @see UTF8Proc.NFC
      def NFC(string)
        JTNORM.normalize(string, JTNORM::Form::NFC)
      end

      # @see UTF8Proc.NFD
      def NFD(string)
        JTNORM.normalize(string, JTNORM::Form::NFD)
      end

      # @see UTF8Proc.NFKC
      def NFKC(string)
        JTNORM.normalize(string, JTNORM::Form::NFKC)
      end

      # @see UTF8Proc.NFKD
      def NFKD(string)
        JTNORM.normalize(string, JTNORM::Form::NFKD)
      end

      # @see UTF8Proc.NFKC_CF
      def NFKC_CF(string)
        NFKC(string).to_java(:string).toLowerCase
      end

      # @see UTF8Proc.normalize
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
