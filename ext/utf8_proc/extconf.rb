# frozen_string_literal: true
# rubocop:disable GlobalVars
require "mkmf"

pkg_config("utf8proc")
unless have_library("utf8proc")
  puts "Compiling local libutf8proc..."

  libutf8proc_dir = File.expand_path(File.join(File.dirname(__FILE__),
                                               "../../vendor/libutf8proc"))
  Dir.chdir(libutf8proc_dir) do
    system("make libutf8proc.a")
    system("rm utf8proc.o")
  end

  dir_config("utf8_proc/utf8_proc",
             [RbConfig::CONFIG["includedir"], libutf8proc_dir],
             [RbConfig::CONFIG["libdir"], libutf8proc_dir])
  $LOCAL_LIBS << " -lutf8proc"
end

$CFLAGS << " -std=c99 -Wno-declaration-after-statement"

create_makefile("utf8_proc/utf8_proc")
