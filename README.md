# UTF8Proc

[![Build Status](https://travis-ci.org/nomoon/utf8_proc.svg?branch=master)](https://travis-ci.org/nomoon/utf8_proc)
[![Dependency Status](https://gemnasium.com/badges/github.com/nomoon/utf8_proc.svg)](https://gemnasium.com/github.com/nomoon/utf8_proc)
[![Gem Version](https://badge.fury.io/rb/utf8_proc.svg)](https://badge.fury.io/rb/utf8_proc)

A simple wrapper around [utf8proc](https://github.com/JuliaLang/utf8proc) for normalizing Unicode strings. Will use the `utf8proc` shared library and headers installed on your system if they are available *(Packages are available. OSX: `brew install utf8proc`, Linux: `libutf8proc-dev` or `utf8proc-devel`)*. Failing that, it will fall-back to compiling the library into the extension.

Currently supports UTF-8/ASCII string input and NFC, NFD, NFKC, NFKD, and NKFC-Casefold forms (US-ASCII strings return an unmodified or case-folded copy). Handles Unicode 9.0 and includes the current official full suite of 9.0 normalization tests.

Quick benchmarks against the [UNF](https://github.com/knu/ruby-unf) gem show `utf8_proc` to be between the same speed (best-case) and ~2x slower (worst-case), averaging about 1.15 to 1.5x slower and improving on complex Unicode strings. *(However, UNF currently only officially supports Unicode 6.0 and does not pass all 9.0 normalization tests.)*

## Installation

Add this line to your application's Gemfile:

```ruby
gem "utf8_proc"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install utf8_proc

## Usage

YARD documentation is available at [rubydoc.info](http://www.rubydoc.info/github/nomoon/utf8_proc)

```ruby
require "utf8_proc"

# Canonical Decomposition, followed by Canonical Composition
UTF8Proc.NFC(utf8_string)

# Canonical Decomposition
UTF8Proc.NFD(utf8_string)

# Compatibility Decomposition, followed by Canonical Composition
UTF8Proc.NFKC(utf8_string)

# Compatibility Decomposition
UTF8Proc.NFKD(utf8_string)

# Compatibility Decomposition, followed by Canonical Composition with Case-folding
UTF8Proc.NFKC_CF(utf8_string)

# Second argument may be any of: [:nfc (default), :nfd, :nfkc, :nfkd, :nfkc_cf]
UTF8Proc.normalize(utf8_string, form = :nfc)

# Version string of loaded libutf8proc
UTF8Proc::LIBRARY_VERSION

# Add normalization methods directly to String class
require "utf8_proc/core_ext/string"

# This enables:
"String".NFC
"String".normalize(:nfc)

```

(Like `unf`) on JRuby the gem will fall-back to using `java.text.normalizer`. The interface remains the same.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nomoon/utf8_proc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
