# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "utf8_proc"

require "io/console"
require "minitest/autorun"

def tputs(string, stream = STDOUT)
  winsize = ::IO.console.winsize
  Array(string).each do |str|
    str = "#{str[0, winsize[1] - 3]}..." if str.length <= winsize[1]
    stream.puts str
  end
end
