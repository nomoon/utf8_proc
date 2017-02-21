# frozen_string_literal: true
require "test_helper"

class UTF8ProcTest < Minitest::Test
  def setup
    @unicode_string = "\u1E9B\u0323".encode("UTF-8")
    @encoding_error = ::RuntimeError
    @encoding_error_msg = "String must be in UTF-8 or US-ASCII encoding."
    @form_error = ::RuntimeError
    @form_error_msg = "Second optional argument must be one of [:nfc, :nfd, :nfkc, :nfkd, :nfkc_cf] (defaults to :nfc)"
  end

  def test_that_it_has_a_version_number
    refute_nil ::UTF8Proc::VERSION
  end

  # NFC

  def test_to_nfc_result
    assert_equal ::UTF8Proc.NFC(@unicode_string).codepoints, [7835, 803]
  end

  def test_to_nfc_encoding
    assert_equal ::UTF8Proc.NFC(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfc_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.NFC(@unicode_string.encode("UTF-16"))
    end
  end

  # NFD

  def test_to_nfd_result
    assert_equal ::UTF8Proc.NFD(@unicode_string).codepoints, [383, 803, 775]
  end

  def test_to_nfd_encoding
    assert_equal ::UTF8Proc.NFD(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfd_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.NFD(@unicode_string.encode("UTF-16"))
    end
  end

  # NFKC

  def test_to_nfkc_result
    assert_equal ::UTF8Proc.NFKC(@unicode_string.upcase).codepoints, [7784]
  end

  def test_to_nfkc_encoding
    assert_equal ::UTF8Proc.NFKC(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfkc_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.NFKC(@unicode_string.encode("UTF-16"))
    end
  end

  # NFKD

  def test_to_nfkd_result
    assert_equal ::UTF8Proc.NFKD(@unicode_string).codepoints, [115, 803, 775]
  end

  def test_to_nfkd_encoding
    assert_equal ::UTF8Proc.NFKD(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfkd_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.NFKD(@unicode_string.encode("UTF-16"))
    end
  end

  # NFKC_CF (Case-folding)

  def test_to_nfkc_cf_result
    assert_equal ::UTF8Proc.NFKC_CF(@unicode_string.upcase).codepoints, [7785]
  end

  def test_to_nfkc_cf_encoding
    assert_equal ::UTF8Proc.NFKC_CF(@unicode_string).encoding, Encoding::UTF_8
  end

  def test_to_nfkc_cf_error
    assert_have_error(@encoding_error_msg, @encoding_error) do
      ::UTF8Proc.NFKC_CF(@unicode_string.encode("UTF-16"))
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

  def test_to_norm_nfkc_cf_result
    assert_equal ::UTF8Proc.normalize(@unicode_string.upcase, :nfkc_cf).codepoints, [7785]
  end

  def test_to_norm_error
    assert_have_error(@form_error_msg, @form_error) do
      ::UTF8Proc.normalize(@unicode_string, :foo)
    end
  end

  # Test against Unicode 9.0 Normalization Data

  def test_normalization_data
    i = 0
    File.open(File.join(__dir__, "NormalizationTest.txt"), "r") do |file|
      file.each_line do |line|
        # Skip line if it's only a comment or header
        next if line.match?(/^(?:\#|\@)/)

        # Determine where the comment portion of the line starts, and split.
        split_point = line.index(" # ")
        tests = line[0..split_point]
        comment = line[(split_point + 3)..-1]

        # Break comment portion into listed chars and description
        desc_chars, description = comment.split(/(?<=[\)])\s/)

        # Trim/split description characters and remove illustrative circles.
        desc_chars = desc_chars.gsub!(/^\(|\u{25CC}|\)$/, "").split(/;\s/)

        # Unescape test sequences into unicode characters.
        tests = tests.split(/;\s?/).map! do |test|
          test.gsub!(/([\h]{4,6}\s?)+/) do |m|
            eval(%("\\u{#{m}}")) # rubocop:disable Eval
          end
        end

        # Be verbose maybe.
        if $DEBUG
          tputs(description, STDERR)
          tputs(desc_chars.inspect, STDERR)
        end

        # Ensure unescaped characters match description characters
        assert_equal tests, desc_chars
        assert_equal ::UTF8Proc.NFC(tests[0]), tests[1]
        assert_equal ::UTF8Proc.NFD(tests[0]), tests[2]
        assert_equal ::UTF8Proc.NFKC(tests[0]), tests[3]
        assert_equal ::UTF8Proc.NFKD(tests[0]), tests[4]
        i += 1
      end
      STDERR.print("(#{i} normalizations tested)") if $VERBOSE
    end
  end
end
