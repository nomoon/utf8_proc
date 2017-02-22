# frozen_string_literal: true
require "test_helper"

class UTF8ProcTest < Minitest::Test
  def setup
    @unistr =        "\u1E9B\u0323"      .encode("UTF-8") # Also NFC
    @unistr_nfd =    "\u017F\u0323\u0307".encode("UTF-8")
    @unistr_nfkc =   "\u1E69"            .encode("UTF-8")
    @unistr_nfkd =   "\u0073\u0323\u0307".encode("UTF-8")

    @unistr_up =     "\u1E60\u0323"      .encode("UTF-8") # Non-normalized
    @unistr_up_nfc = "\u1E68"            .encode("UTF-8")

    @encoding_error = ::EncodingError
    @form_error = ::ArgumentError
  end

  def test_that_it_has_a_version_number
    refute_nil ::UTF8Proc::VERSION
  end

  # NFC

  def test_to_nfc_result
    assert_equal ::UTF8Proc.NFC(@unistr_up), @unistr_up_nfc
  end

  def test_to_nfc_encoding
    assert_equal ::UTF8Proc.NFC(@unistr_up).encoding, Encoding::UTF_8
  end

  def test_to_nfc_error
    assert_raises(@encoding_error) do
      ::UTF8Proc.NFC(@unistr_up.encode("UTF-16"))
    end
  end

  # NFD

  def test_to_nfd_result
    assert_equal ::UTF8Proc.NFD(@unistr), @unistr_nfd
  end

  def test_to_nfd_encoding
    assert_equal ::UTF8Proc.NFD(@unistr).encoding, Encoding::UTF_8
  end

  def test_to_nfd_error
    assert_raises(@encoding_error) do
      ::UTF8Proc.NFD(@unistr.encode("UTF-16"))
    end
  end

  # NFKC

  def test_to_nfkc_result
    assert_equal ::UTF8Proc.NFKC(@unistr), @unistr_nfkc
  end

  def test_to_nfkc_encoding
    assert_equal ::UTF8Proc.NFKC(@unistr).encoding, Encoding::UTF_8
  end

  def test_to_nfkc_error
    assert_raises(@encoding_error) do
      ::UTF8Proc.NFKC(@unistr.encode("UTF-16"))
    end
  end

  # NFKD

  def test_to_nfkd_result
    assert_equal ::UTF8Proc.NFKD(@unistr), @unistr_nfkd
  end

  def test_to_nfkd_encoding
    assert_equal ::UTF8Proc.NFKD(@unistr).encoding, Encoding::UTF_8
  end

  def test_to_nfkd_error
    assert_raises(@encoding_error) do
      ::UTF8Proc.NFKD(@unistr.encode("UTF-16"))
    end
  end

  # NFKC_CF (Case-folding)

  def test_to_nfkc_cf_result
    assert_equal ::UTF8Proc.NFKC_CF(@unistr_up), @unistr_nfkc
  end

  def test_to_nfkc_cf_encoding
    assert_equal ::UTF8Proc.NFKC_CF(@unistr_up).encoding, Encoding::UTF_8
  end

  def test_to_nfkc_cf_error
    assert_raises(@encoding_error) do
      ::UTF8Proc.NFKC_CF(@unistr_up.encode("UTF-16"))
    end
  end

  # Normalizer

  def test_to_norm_default_result
    assert_equal ::UTF8Proc.normalize(@unistr_up), @unistr_up_nfc
  end

  def test_to_norm_nfc_result
    assert_equal ::UTF8Proc.normalize(@unistr_up, :nfc), @unistr_up_nfc
  end

  def test_to_norm_nfd_result
    assert_equal ::UTF8Proc.normalize(@unistr, :nfd), @unistr_nfd
  end

  def test_to_norm_nfkc_result
    assert_equal ::UTF8Proc.normalize(@unistr, :nfkc), @unistr_nfkc
  end

  def test_to_norm_nfkd_result
    assert_equal ::UTF8Proc.normalize(@unistr, :nfkd), @unistr_nfkd
  end

  def test_to_norm_nfkc_cf_result
    assert_equal ::UTF8Proc.normalize(@unistr_up, :nfkc_cf), @unistr_nfkc
  end

  def test_to_norm_error
    assert_raises(@form_error) do
      ::UTF8Proc.normalize(@unistr, :foo)
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
