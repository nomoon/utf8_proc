# frozen_string_literal: true
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

if defined?(JRUBY_VERSION)
  task default: :test
else
  require "rake/extensiontask"

  task build: :compile

  Rake::ExtensionTask.new("utf8_proc") do |ext|
    ext.lib_dir = "lib/utf8_proc"
  end

  task default: %i[clobber compile test]
end
