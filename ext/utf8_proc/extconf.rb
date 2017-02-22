# frozen_string_literal: true
# rubocop:disable GlobalVars
require "mkmf"

$CFLAGS << " -std=c99 -Wno-declaration-after-statement -Wno-unknown-warning-option"

pkg_config("utf8proc")

have_library("utf8proc") || abort("This extension requires the utf8proc library.")

create_makefile("utf8_proc/utf8_proc")
