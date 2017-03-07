# frozen_string_literal: true
# rubocop:disable UnneededInterpolation
require "test_helper"

class UTF8ProcTest < Minitest::Test
  def setup
    @asciistr = "ASCII STRING".encode("US-ASCII")
    @unistr_denormal = "\u03D3\u{03D2 0301}\u038E\u{03A5 0301}\u00AD" \
                       "\u03D4\u{03D2 0308}\u03AB\u{03A5 0308}\u200C" \
                       "\u1E9B\u{017F 0307}\u1E61\u{0073 0307}\u200D"

    @unistr_nfc = "\u03D3\u03D3\u038E\u038E\u00AD" \
                  "\u03D4\u03D4\u03AB\u03AB\u200C" \
                  "\u1E9B\u1E9B\u1E61\u1E61\u200D"

    @unistr_nfd = "\u{03D2 0301}\u{03D2 0301}\u{03A5 0301}\u{03A5 0301}\u00AD" \
                  "\u{03D2 0308}\u{03D2 0308}\u{03A5 0308}\u{03A5 0308}\u200C" \
                  "\u{017F 0307}\u{017F 0307}\u{0073 0307}\u{0073 0307}\u200D"

    @unistr_nfkc = "\u038E\u038E\u038E\u038E\u00AD" \
                   "\u03AB\u03AB\u03AB\u03AB\u200C" \
                   "\u1E61\u1E61\u1E61\u1E61\u200D"

    @unistr_nfkd = "\u{03A5 0301}\u{03A5 0301}\u{03A5 0301}\u{03A5 0301}\u00AD" \
                   "\u{03A5 0308}\u{03A5 0308}\u{03A5 0308}\u{03A5 0308}\u200C" \
                   "\u{0073 0307}\u{0073 0307}\u{0073 0307}\u{0073 0307}\u200D"

    @unistr_nfkc_cf = "\u03CD\u03CD\u03CD\u03CD" \
                      "\u03CB\u03CB\u03CB\u03CB" \
                      "\u1E61\u1E61\u1E61\u1E61"

    @encoding_error = ::EncodingError
    @form_error = ::ArgumentError
  end

  def test_that_it_has_a_version_number
    refute_empty ::UTF8Proc::VERSION
  end

  def test_that_it_has_a_library_version_number
    refute_empty ::UTF8Proc::LIBRARY_VERSION
  end

  # Test UTF8Proc.normalize against Unicode 9.0 Normalization Data
  normalization_file = File.join(File.dirname(__FILE__), "NormalizationTest.txt")
  File.open(normalization_file, "r") do |file|
    part = 0
    file.each_line do |line|
      # Skip line if it's only a comment or header
      next if line =~ /^(?:\#)/
      if p = line[/^@Part([0-9]+)/, 1] # rubocop:disable AssignmentInCondition
        part = p.to_i
        next
      end

      # Determine where the comment portion of the line starts, and split.
      split_point = line.index(" # ")
      tests = line[0..split_point]

      # Unescape test sequences into unicode characters.
      tests = tests.split(/;\s?/).map! do |test|
        test.gsub!(/([\h]{4,6}\s?)+/) do |m|
          eval(%("\\u{#{m}}")) # rubocop:disable Eval
        end
      end

      codes = tests[0].codepoints.map { |c| c.to_s(16).upcase.rjust(4, "0") }
      method_name = "test_normalization_data_p#{part}_#{codes.join('')}"
      define_method(method_name) do
        skip if jruby?
        assert_equal "#{tests[1]}", ::UTF8Proc.NFC("#{tests[0]}")
        assert_equal "#{tests[2]}", ::UTF8Proc.NFD("#{tests[0]}")
        assert_equal "#{tests[3]}", ::UTF8Proc.NFKC("#{tests[0]}")
        assert_equal "#{tests[4]}", ::UTF8Proc.NFKD("#{tests[0]}")
      end
    end
  end

  # Test NFKC_CF against a pile of data
  normalization_file = File.join(File.dirname(__FILE__), "nfkc-casefold-test.txt")
  File.open(normalization_file, "r") do |file|
    i = 1
    file.each_slice(3) do |lines|
      src = lines[0].chomp
      correct = lines[1].chomp
      method_name = "test_normalization_data_nfkc_cf_#{i}"
      define_method(method_name) do
        skip if jruby?
        assert_equal "#{correct}", ::UTF8Proc.NFKC_CF("#{src}")
      end
      i += 1
    end
  end

  # NFC

  def test_to_nfc_result
    assert_equal @unistr_nfc, ::UTF8Proc.nfc(@unistr_denormal)
  end

  def test_to_nfc_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfc(@unistr_denormal).encoding
  end

  def test_to_nfc_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfc(@unistr_denormal.encode("UTF-16"))
    end
  end

  # NFD

  def test_to_nfd_result
    assert_equal @unistr_nfd, ::UTF8Proc.nfd(@unistr_denormal)
  end

  def test_to_nfd_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfd(@unistr_denormal).encoding
  end

  def test_to_nfd_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfd(@unistr_denormal.encode("UTF-16"))
    end
  end

  # NFKC

  def test_to_nfkc_result
    assert_equal @unistr_nfkc, ::UTF8Proc.nfkc(@unistr_denormal)
  end

  def test_to_nfkc_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfkc(@unistr_denormal).encoding
  end

  def test_to_nfkc_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfkc(@unistr_denormal.encode("UTF-16"))
    end
  end

  # NFKD

  def test_to_nfkd_result
    assert_equal @unistr_nfkd, ::UTF8Proc.nfkd(@unistr_denormal)
  end

  def test_to_nfkd_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfkd(@unistr_denormal).encoding
  end

  def test_to_nfkd_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfkd(@unistr_denormal.encode("UTF-16"))
    end
  end

  # NFKC_CF (Case-folding)

  def test_to_nfkc_cf_result
    assert_equal @unistr_nfkc_cf, ::UTF8Proc.nfkc_cf(@unistr_denormal)
  end

  def test_to_nfkc_cf_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfkc_cf(@unistr_denormal).encoding
  end

  def test_to_nfkc_cf_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfkc_cf(@unistr_denormal.encode("UTF-16"))
    end
  end

  # Normalizer

  def test_to_norm_default_result
    assert_equal @unistr_nfc, ::UTF8Proc.normalize(@unistr_denormal)
  end

  def test_to_norm_nfc_result
    assert_equal @unistr_nfc, ::UTF8Proc.normalize(@unistr_denormal, :nfc)
  end

  def test_to_norm_nfd_result
    assert_equal @unistr_nfd, ::UTF8Proc.normalize(@unistr_denormal, :nfd)
  end

  def test_to_norm_nfkc_result
    assert_equal @unistr_nfkc, ::UTF8Proc.normalize(@unistr_denormal, :nfkc)
  end

  def test_to_norm_nfkd_result
    assert_equal @unistr_nfkd, ::UTF8Proc.normalize(@unistr_denormal, :nfkd)
  end

  def test_to_norm_nfkc_cf_result
    assert_equal @unistr_nfkc_cf, ::UTF8Proc.normalize(@unistr_denormal, :nfkc_cf)
  end

  def test_to_norm_error
    assert_raises(@form_error) do
      ::UTF8Proc.normalize(@unistr_denormal, :foo)
    end
  end

  # A few separate tests for String extension

  def test_self_to_nfc_encoding
    assert_equal Encoding::UTF_8, @unistr_denormal.NFC.encoding
  end

  def test_self_to_nfc_error
    skip if jruby?
    assert_raises(@encoding_error) do
      @unistr_denormal.encode("UTF-16").NFC
    end
  end

  def test_self_to_norm_error
    assert_raises(@form_error) do
      @unistr_denormal.normalize(:foo)
    end
  end

  # US-ASCII normalization should return a duplicate identical string
  # unless case-folding
  def test_to_norm_usascii
    result = ::UTF8Proc.normalize(@asciistr)
    assert_equal @asciistr, result
    assert_equal Encoding::US_ASCII, result.encoding unless jruby?
    refute_same @asciistr, result
  end

  def test_to_norm_usascii_casefold
    result = ::UTF8Proc.normalize(@asciistr, :nfkc_cf)
    assert_equal @asciistr.downcase, result
    assert_equal Encoding::US_ASCII, result.encoding unless jruby?
  end
end
