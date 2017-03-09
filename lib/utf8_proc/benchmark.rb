# frozen_string_literal: true

module UTF8Proc
  # Benchmark module for comparing the speed of *UTF8Proc* and *UNF*
  module Benchmark
    module_function

    # Various different normalizations of Unicode characters.
    @test_arr = ["quick", "brown", "fox", "jumped", "over", "lazy", "dog",
                 "QUICK", "BROWN", "FOX", "JUMPED", "OVER", "LAZY", "DOG",
                 "\u{03D3}", "\u{03D2 0301}", "\u{038E}", "\u{03A5 0301}",
                 "\u{03D4}", "\u{03D2 0308}", "\u{03AB}", "\u{03A5 0308}",
                 "\u{1E9B}", "\u{017F 0307}", "\u{1E61}", "\u{0073 0307}",
                 "\u{1D160}", "\u{1D158 1D165 1D16E}",
                 "\u{1F82}", "\u{03B1 0313 0300 0345}",
                 "\u{FDFA}", "\u{0635 0644 0649 0020 0627 0644 0644 0647}" \
                 "\u{0020 0639 0644 064A 0647 0020 0648 0633 0644 0645}"] * 2
    @test_arr.concat([" "] * (@test_arr.length / 3))
    @test_strings = Array.new(10) { @test_arr.sample(15).join("").freeze }

    # Runs the benchmark and displays the results.
    # @param time [Integer] number of seconds to run each test
    # @param warmup [Integer] number of seconds to warm-up each test
    # @param tests [Array<Symbol>] normalization forms for the test
    def run(time = 10, warmup = 2, tests = %i[nfc nfd nfkc nfkd nfkc_cf])
      begin
        require "benchmark/ips"
      rescue LoadError
        warn "Benchmarks require the `benchmark-ips` gem."
        return
      end

      begin
        require "unf"
        @unf = true
      rescue LoadError
        warn "`unf` gem not found. Skipping benchmarks for it."
        @unf = false
      end

      puts "\nBenchmark strings:\n\n * #{@test_strings.join("\n * ")}\n\n"
      Array(tests).each { |form| send("run_#{form}".to_sym, time, warmup) }
      true
    end

    def run_nfc(time, warmup)
      ::Benchmark.ips do |x|
        x.report("UTF8Proc NFC") do
          UTF8Proc.normalize(@test_strings.sample, :nfc)
        end

        x.report("Ruby NFC") do
          @test_strings.sample.unicode_normalize(:nfc)
        end

        if @unf
          x.config(time: time, warmup: warmup)
          x.report("UNF NFC") do
            UNF::Normalizer.normalize(@test_strings.sample, :nfc)
          end
        end

        x.compare!
      end
    end

    def run_nfd(time, warmup)
      ::Benchmark.ips do |x|
        x.config(time: time, warmup: warmup)
        x.report("UTF8Proc NFD") do
          UTF8Proc.normalize(@test_strings.sample, :nfd)
        end

        x.report("Ruby NFD") do
          @test_strings.sample.unicode_normalize(:nfd)
        end

        if @unf
          x.report("UNF NFD") do
            UNF::Normalizer.normalize(@test_strings.sample, :nfd)
          end
        end
        x.compare!
      end
    end

    def run_nfkc(time, warmup)
      ::Benchmark.ips do |x|
        x.config(time: time, warmup: warmup)
        x.report("UTF8Proc NFKC") do
          UTF8Proc.normalize(@test_strings.sample, :nfkc)
        end

        x.report("Ruby NFKC") do
          @test_strings.sample.unicode_normalize(:nfkc)
        end

        if @unf
          x.report("UNF NFKC") do
            UNF::Normalizer.normalize(@test_strings.sample, :nfkc)
          end
        end
        x.compare!
      end
    end

    def run_nfkd(time, warmup)
      ::Benchmark.ips do |x|
        x.config(time: time, warmup: warmup)
        x.report("UTF8Proc NFKD") do
          UTF8Proc.normalize(@test_strings.sample, :nfkd)
        end

        x.report("Ruby NFKD") do
          @test_strings.sample.unicode_normalize(:nfkd)
        end

        if @unf
          x.report("UNF NFKD") do
            UNF::Normalizer.normalize(@test_strings.sample, :nfkd)
          end
        end
        x.compare!
      end
    end

    def run_nfkc_cf(time, warmup)
      ::Benchmark.ips do |x| # rubocop:disable BlockLength
        x.config(time: time, warmup: warmup)
        x.report("UTF8Proc NFKC_CF") do
          UTF8Proc.normalize(@test_strings.sample, :nfkc_cf)
        end

        if RUBY_VERSION >= "2.4"
          x.report("Ruby NFKC.downcase!(:fold)") do
            @test_strings.sample.unicode_normalize(:nfkc).downcase!(:fold)
          end

          if @unf
            x.report("UNF NFKC.downcase!(:fold)") do
              UNF::Normalizer.normalize(@test_strings.sample, :nfkc).downcase!(:fold)
            end
          end
        else
          warn "WARNING: It's not certain that your String#downcase! method " \
               "is Unicode-aware.\n" \
               "         (This usually requires Ruby 2.4 and up.)\n" \
               "         Falling back to #downcase! from #downcase!(:fold)"

          x.report("Ruby NFKC.downcase!(:fold)") do
            @test_strings.sample.unicode_normalize(:nfkc).downcase!(:fold)
          end

          if @unf
            x.report("UNF NFKC.downcase!") do
              UNF::Normalizer.normalize(@test_strings.sample, :nfkc).downcase!
            end
          end
        end
        x.compare!
      end
    end

    private_class_method :run_nfc, :run_nfd, :run_nfkc, :run_nfkd, :run_nfkc_cf
  end
end
