# frozen_string_literal: true
# rubocop:disable GlobalVars
require "mkmf"

$CFLAGS << " -Wall"

have_library("utf8proc") || abort("This extension requires the utf8proc library.")

create_makefile("utf8_proc/utf8_proc")
