# frozen_string_literal: true
# rubocop:disable MethodLength
module UTF8Proc
  module Benchmark
    module_function

    def run
      require "benchmark/ips"
      require "unf"
      # Various different normalizations of Unicode characters.
      test_arr = ["quick", "brown", "fox", "jumped", "over", "lazy", "dog",
                  "QUICK", "BROWN", "FOX", "JUMPED", "OVER", "LAZY", "DOG",
                  "\u{03D3}", "\u{03D2 0301}", "\u{038E}", "\u{03A5 0301}",
                  "\u{03D4}", "\u{03D2 0308}", "\u{03AB}", "\u{03A5 0308}",
                  "\u{1E9B}", "\u{017F 0307}", "\u{1E61}", "\u{0073 0307}",
                  "\u{1D160}", "\u{1D158 1D165 1D16E}",
                  "\u{1F82}", "\u{03B1 0313 0300 0345}",
                  "\u{FDFA}", "\u{0635 0644 0649 0020 0627 0644 0644 0647}" \
                  "\u{0020 0639 0644 064A 0647 0020 0648 0633 0644 0645}"] * 10
      test_arr.concat([" "] * (test_arr.length / 4))

      test_strings = Array.new(20) { test_arr.sample(30).join("") }
      puts "\nBenchmark strings:\n\n * #{test_strings.join("\n * ")}\n\n"

      ::Benchmark.ips do |x|
        x.config(time: 10, warmup: 2)
        x.report("UNF NFC") do
          UNF::Normalizer.normalize(test_strings.sample, :nfc)
        end

        x.report("UTF8Proc NFC") do
          UTF8Proc.normalize(test_strings.sample, :nfc)
        end
        x.compare!
      end

      ::Benchmark.ips do |x|
        x.config(time: 10, warmup: 2)
        x.report("UNF NFD") do
          UNF::Normalizer.normalize(test_strings.sample, :nfd)
        end

        x.report("UTF8Proc NFD") do
          UTF8Proc.normalize(test_strings.sample, :nfd)
        end
        x.compare!
      end

      ::Benchmark.ips do |x|
        x.config(time: 10, warmup: 2)
        x.report("UNF NFKC") do
          UNF::Normalizer.normalize(test_strings.sample, :nfkc)
        end

        x.report("UTF8Proc NFKC") do
          UTF8Proc.normalize(test_strings.sample, :nfkc)
        end
        x.compare!
      end

      ::Benchmark.ips do |x|
        x.config(time: 10, warmup: 2)
        x.report("UNF NFKD") do
          UNF::Normalizer.normalize(test_strings.sample, :nfkd)
        end

        x.report("UTF8Proc NFKD") do
          UTF8Proc.normalize(test_strings.sample, :nfkd)
        end
        x.compare!
      end

      ::Benchmark.ips do |x|
        x.config(time: 10, warmup: 2)
        x.report("UNF NFKC with .downcase") do
          UNF::Normalizer.normalize(test_strings.sample, :nfkc).downcase
        end

        x.report("UTF8Proc NFKC_CF") do
          UTF8Proc.normalize(test_strings.sample, :nfkc_cf)
        end
        x.compare!
      end
      true
    end
  end
end
