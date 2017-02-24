# frozen_string_literal: true
# rubocop:disable GlobalVars
require "mkmf"

pkg_config("utf8proc")
unless have_library("utf8proc")
  puts "Compiling local libutf8proc..."

  libutf8proc_dir = File.expand_path(
    File.join(File.dirname(__FILE__), "../../vendor/libutf8proc")
  )

  $VPATH << libutf8proc_dir
  $srcs = ["utf8_proc.c", "utf8proc.c"]
  $CFLAGS << " -I#{libutf8proc_dir}"
end

$CFLAGS << " -std=c99 -Wno-declaration-after-statement"

create_makefile("utf8_proc/utf8_proc")
