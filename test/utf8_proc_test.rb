# frozen_string_literal: true
require "test_helper"

class UTF8ProcTest < Minitest::Test
  prove_it!

  def setup
    @cstr = "ASCII STRING".encode("US-ASCII")

    # This string contains all 4 different normalizations, as well as
    # ignorable characters and some improperly ordered combinations.
    @ustr_denormal = "\u03D3\u{03D2 0301}\u038E\u{03A5 0301}\u00AD" \
                     "\u03D4\u{03D2 0308}\u03AB\u{03A5 0308}\u200C" \
                     "\u1E9B\u{017F 0307}\u1E61\u{0073 0307}\u200D" \
                     "\u{1E9B 0323}\u{017F 0307 0323}\u1E69\u{0073 0307 0323}"

    @ustr_nfc = "\u03D3\u03D3\u038E\u038E\u00AD" \
                "\u03D4\u03D4\u03AB\u03AB\u200C" \
                "\u1E9B\u1E9B\u1E61\u1E61\u200D" \
                "\u{1E9B 0323}\u{1E9B 0323}\u1E69\u1E69"

    @ustr_nfd = "\u{03D2 0301}\u{03D2 0301}\u{03A5 0301}\u{03A5 0301}\u00AD" \
                "\u{03D2 0308}\u{03D2 0308}\u{03A5 0308}\u{03A5 0308}\u200C" \
                "\u{017F 0307}\u{017F 0307}\u{0073 0307}\u{0073 0307}\u200D" \
                "\u{017F 0323 0307}\u{017F 0323 0307}\u{0073 0323 0307}" \
                "\u{0073 0323 0307}"

    @ustr_nfkc = "\u038E\u038E\u038E\u038E\u00AD" \
                 "\u03AB\u03AB\u03AB\u03AB\u200C" \
                 "\u1E61\u1E61\u1E61\u1E61\u200D" \
                 "\u1E69\u1E69\u1E69\u1E69"

    @ustr_nfkd = "\u{03A5 0301}\u{03A5 0301}\u{03A5 0301}\u{03A5 0301}\u00AD" \
                 "\u{03A5 0308}\u{03A5 0308}\u{03A5 0308}\u{03A5 0308}\u200C" \
                 "\u{0073 0307}\u{0073 0307}\u{0073 0307}\u{0073 0307}\u200D" \
                 "\u{0073 0323 0307}\u{0073 0323 0307}\u{0073 0323 0307}" \
                 "\u{0073 0323 0307}"

    @ustr_nfkc_cf = "\u03CD\u03CD\u03CD\u03CD" \
                    "\u03CB\u03CB\u03CB\u03CB" \
                    "\u1E61\u1E61\u1E61\u1E61" \
                    "\u1E69\u1E69\u1E69\u1E69"

    @encoding_error = ::EncodingError
    @form_error = ::ArgumentError
  end

  def test_that_it_has_a_version_number
    refute_empty ::UTF8Proc::VERSION
  end

  def test_that_it_has_a_library_version_number
    refute_empty ::UTF8Proc::LIBRARY_VERSION
  end

  # Some UNF tests so that we can feel better about ourselves

  def test_unf_nfc
    assert_equal @ustr_nfc, UNF::Normalizer.normalize(@ustr_denormal, :nfc)
  end

  def test_unf_nfd
    assert_equal @ustr_nfd, UNF::Normalizer.normalize(@ustr_denormal, :nfd)
  end

  def test_unf_nfkc
    assert_equal @ustr_nfkc, UNF::Normalizer.normalize(@ustr_denormal, :nfkc)
  end

  def test_unf_nfkd
    assert_equal @ustr_nfkd, UNF::Normalizer.normalize(@ustr_denormal, :nfkd)
  end

  # Test UTF8Proc.normalize against Unicode 9.0 Normalization Data
  normalization_file = File.join(File.dirname(__FILE__), "NormalizationTest.txt")
  part = 0
  File.open(normalization_file, "r").each_line do |line|
    # Skip line if it's only a comment or header
    next if line.match(/^#|^@Part([0-9]+)/) do |m|
      part = m[1].to_i if m[1]
      true
    end

    # Determine where the comment portion of the line starts, and split.
    # Unescape test sequences into unicode characters.
    tests = line[0..line.index(" # ")].split(/;\s?/).map! do |test|
      test.scan(/\b[\h]{4,6}\b/).map!(&:hex).pack("U*")
    end

    codes = tests[0].codepoints.map! { |c| "%04x" % c }.join("_")
    method_name = "test_normalization_data_p#{part}_#{codes}"
    define_method(method_name) do
      skip if jruby?
      assert_equal tests[1], ::UTF8Proc.NFC(tests[0]), "NFC"
      assert_equal tests[2], ::UTF8Proc.NFD(tests[0]), "NFD"
      assert_equal tests[3], ::UTF8Proc.NFKC(tests[0]), "NFKC"
      assert_equal tests[4], ::UTF8Proc.NFKD(tests[0]), "NFKD"
    end
  end

  # Test NFKC_CF against a pile of data
  normalization_file = File.join(File.dirname(__FILE__), "nfkc-casefold-test.txt")
  File.open(normalization_file, "r").each_slice(3).with_index do |lines, i|
    src_str = lines[0].chomp
    cor_str = lines[1].chomp
    method_name = "test_normalization_data_nfkc_cf_#{i + 1}"
    define_method(method_name) do
      skip if jruby?
      assert_equal cor_str, ::UTF8Proc.NFKC_CF(src_str)
    end
  end

  # NFC

  def test_to_nfc_result
    assert_equal @ustr_nfc, ::UTF8Proc.nfc(@ustr_denormal)
  end

  def test_to_nfc_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfc(@ustr_denormal).encoding
  end

  def test_to_nfc_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfc(@ustr_denormal.encode("UTF-16"))
    end
  end

  # NFD

  def test_to_nfd_result
    assert_equal @ustr_nfd, ::UTF8Proc.nfd(@ustr_denormal)
  end

  def test_to_nfd_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfd(@ustr_denormal).encoding
  end

  def test_to_nfd_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfd(@ustr_denormal.encode("UTF-16"))
    end
  end

  # NFKC

  def test_to_nfkc_result
    assert_equal @ustr_nfkc, ::UTF8Proc.nfkc(@ustr_denormal)
  end

  def test_to_nfkc_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfkc(@ustr_denormal).encoding
  end

  def test_to_nfkc_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfkc(@ustr_denormal.encode("UTF-16"))
    end
  end

  # NFKD

  def test_to_nfkd_result
    assert_equal @ustr_nfkd, ::UTF8Proc.nfkd(@ustr_denormal)
  end

  def test_to_nfkd_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfkd(@ustr_denormal).encoding
  end

  def test_to_nfkd_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfkd(@ustr_denormal.encode("UTF-16"))
    end
  end

  # NFKC_CF (Case-folding)

  def test_to_nfkc_cf_result
    assert_equal @ustr_nfkc_cf, ::UTF8Proc.nfkc_cf(@ustr_denormal)
  end

  def test_to_nfkc_cf_encoding
    assert_equal Encoding::UTF_8, ::UTF8Proc.nfkc_cf(@ustr_denormal).encoding
  end

  def test_to_nfkc_cf_error
    skip if jruby?
    assert_raises(@encoding_error) do
      ::UTF8Proc.nfkc_cf(@ustr_denormal.encode("UTF-16"))
    end
  end

  # Normalizer

  def test_to_norm_default_result
    assert_equal @ustr_nfc, ::UTF8Proc.normalize(@ustr_denormal)
  end

  def test_to_norm_nfc_result
    assert_equal @ustr_nfc, ::UTF8Proc.normalize(@ustr_denormal, :nfc)
  end

  def test_to_norm_nfd_result
    assert_equal @ustr_nfd, ::UTF8Proc.normalize(@ustr_denormal, :nfd)
  end

  def test_to_norm_nfkc_result
    assert_equal @ustr_nfkc, ::UTF8Proc.normalize(@ustr_denormal, :nfkc)
  end

  def test_to_norm_nfkd_result
    assert_equal @ustr_nfkd, ::UTF8Proc.normalize(@ustr_denormal, :nfkd)
  end

  def test_to_norm_nfkc_cf_result
    assert_equal @ustr_nfkc_cf, ::UTF8Proc.normalize(@ustr_denormal, :nfkc_cf)
  end

  def test_to_norm_error
    assert_raises(@form_error) do
      ::UTF8Proc.normalize(@ustr_denormal, :foo)
    end
  end

  # A few separate tests for String extension

  def test_self_to_nfc_encoding
    assert_equal Encoding::UTF_8, @ustr_denormal.NFC.encoding
  end

  def test_self_to_nfc_error
    skip if jruby?
    assert_raises(@encoding_error) do
      @ustr_denormal.encode("UTF-16").NFC
    end
  end

  def test_self_to_norm_error
    assert_raises(@form_error) do
      @ustr_denormal.normalize(:foo)
    end
  end

  # US-ASCII normalization should return a duplicate identical string
  # unless case-folding
  def test_to_norm_usascii
    result = ::UTF8Proc.normalize(@cstr)
    assert_equal @cstr, result
    assert_equal Encoding::US_ASCII, result.encoding unless jruby?
    refute_same @cstr, result
  end

  def test_to_norm_usascii_casefold
    result = ::UTF8Proc.normalize(@cstr, :nfkc_cf)
    assert_equal @cstr.downcase, result
    assert_equal Encoding::US_ASCII, result.encoding unless jruby?
  end
end
