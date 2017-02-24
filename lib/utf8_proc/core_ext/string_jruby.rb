# frozen_string_literal: true
# rubocop:disable MethodName

# This file should only be required within JRuby

require "java"
require "utf8_proc"

class String
  def NFC
    ::UTF8Proc.NFC(self)
  end

  def NFD
    ::UTF8Proc.NFD(self)
  end

  def NFKC
    ::UTF8Proc.NFKC(self)
  end

  def NFKD
    ::UTF8Proc.NFKD(self)
  end

  def NFKC_CF
    ::UTF8Proc.NFKC_CF(self)
  end

  def normalize(form = :nfc)
    ::UTF8Proc.normalize(self, form)
  end
end
