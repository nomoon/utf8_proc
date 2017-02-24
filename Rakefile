# frozen_string_literal: true
require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rake/testtask"

RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

if RUBY_ENGINE == "jruby"
  task default: %i[rubocop test]
else
  require "rake/extensiontask"

  task build: :compile

  Rake::ExtensionTask.new("utf8_proc") do |ext|
    ext.lib_dir = "lib/utf8_proc"
  end

  task default: %i[rubocop clobber compile test]
end
