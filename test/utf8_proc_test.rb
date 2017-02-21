# frozen_string_literal: true
require "test_helper"

class UTF8ProcTest < Minitest::Test
  def setup
    @unicode_string = "\u1E9B\u0323".encode("UTF-8")
    @encoding_error = ::RuntimeError
    @encoding_error_msg = "String must be in UTF-8 or US-ASCII encoding."
    @form_error = ::RuntimeError
    @form_error_msg = "Second optional argument must be one of [:nfc, :nfd, :nfkc, :nfkd] (defaults to :nfc)"
  end

  def test_that_it_has_a_version_number
    refute_nil ::UTF8Proc::VERSION
  end

  # NFC

  def test_to_nfc_result
    assert_equal ::UTF8Proc.to_NFC(@unicode_string).codepoints, [7835, 803]
  end

  def test_to_nfc_encoding
    assert_equal ::UTF8Proc.to_NFC(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfc_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.to_NFC(@unicode_string.encode("UTF-16"))
    end
  end

  # NFD

  def test_to_nfd_result
    assert_equal ::UTF8Proc.to_NFD(@unicode_string).codepoints, [383, 803, 775]
  end

  def test_to_nfd_encoding
    assert_equal ::UTF8Proc.to_NFD(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfd_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.to_NFD(@unicode_string.encode("UTF-16"))
    end
  end

  # NFKC

  def test_to_nfkc_result
    assert_equal ::UTF8Proc.to_NFKC(@unicode_string).codepoints, [7785]
  end

  def test_to_nfkc_encoding
    assert_equal ::UTF8Proc.to_NFKC(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfkc_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.to_NFKC(@unicode_string.encode("UTF-16"))
    end
  end

  # NFKD

  def test_to_nfkd_result
    assert_equal ::UTF8Proc.to_NFKD(@unicode_string).codepoints, [115, 803, 775]
  end

  def test_to_nfkd_encoding
    assert_equal ::UTF8Proc.to_NFKD(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfkd_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.to_NFKD(@unicode_string.encode("UTF-16"))
    end
  end

  # Normalizer

  def test_to_norm_default_result
    assert_equal ::UTF8Proc.normalize(@unicode_string).codepoints, [7835, 803]
  end

  def test_to_norm_nfc_result
    assert_equal ::UTF8Proc.normalize(@unicode_string, :nfc).codepoints, [7835, 803]
  end

  def test_to_norm_nfd_result
    assert_equal ::UTF8Proc.normalize(@unicode_string, :nfd).codepoints, [383, 803, 775]
  end

  def test_to_norm_nfkc_result
    assert_equal ::UTF8Proc.normalize(@unicode_string, :nfkc).codepoints, [7785]
  end

  def test_to_norm_nfkd_result
    assert_equal ::UTF8Proc.normalize(@unicode_string, :nfkd).codepoints, [115, 803, 775]
  end

  def test_to_norm_error
    assert_have_error(@form_error_msg, @form_error) do
      ::UTF8Proc.normalize(@unicode_string, :foo)
    end
  end
end
