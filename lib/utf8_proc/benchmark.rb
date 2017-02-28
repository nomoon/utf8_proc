# frozen_string_literal: true
# rubocop:disable CyclomaticComplexity, MethodLength
module UTF8Proc
  module Benchmark
    module_function

    def run
      require "benchmark/ips"
      require "unf"
      test_string = "\u{FDFA} "
      test_string *= 20

      test_string_nfc = test_string.unicode_normalize(:nfc)
      test_string_nfd = test_string.unicode_normalize(:nfd)
      test_string_nfkc = test_string.unicode_normalize(:nfkc)
      test_string_nfkd = test_string.unicode_normalize(:nfkd)

      ::Benchmark.ips do |x|
        x.report("UNF NFC") do
          raise unless UNF::Normalizer.normalize(test_string_nfd, :nfc) == test_string_nfc
        end

        x.report("UTF8Proc NFC") do
          raise unless UTF8Proc.normalize(test_string_nfd, :nfc) == test_string_nfc
        end
        x.compare!
      end

      ::Benchmark.ips do |x|
        x.report("UNF NFD") do
          raise unless UNF::Normalizer.normalize(test_string, :nfd) == test_string_nfd
        end

        x.report("UTF8Proc NFD") do
          raise unless UTF8Proc.normalize(test_string, :nfd) == test_string_nfd
        end
        x.compare!
      end

      ::Benchmark.ips do |x|
        x.report("UNF NFKC") do
          raise unless UNF::Normalizer.normalize(test_string, :nfkc) == test_string_nfkc
        end

        x.report("UTF8Proc NFKC") do
          raise unless UTF8Proc.normalize(test_string, :nfkc) == test_string_nfkc
        end
        x.compare!
      end

      ::Benchmark.ips do |x|
        x.report("UNF NFKD") do
          raise unless UNF::Normalizer.normalize(test_string, :nfkd) == test_string_nfkd
        end

        x.report("UTF8Proc NFKD") do
          raise unless UTF8Proc.normalize(test_string, :nfkd) == test_string_nfkd
        end
        x.compare!
      end
      true
    end
  end
end
