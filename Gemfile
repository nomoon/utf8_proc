# frozen_string_literal: true
source "https://rubygems.org"

# Eagerly load a version of the OpenSSL gem on MRI Ruby 2.4
# Workaround for https://github.com/bundler/bundler/issues/5235
if defined?(RUBY_DESCRIPTION) && RUBY_DESCRIPTION.start_with?("ruby 2.4")
  gem "openssl"
end

# Specify your gem's dependencies in icu_test.gemspec
gemspec
