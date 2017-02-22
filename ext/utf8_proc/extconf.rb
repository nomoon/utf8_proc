# frozen_string_literal: true
require "mkmf"

pkg_config("utf8proc")

have_library("utf8proc") || abort("This extension requires the utf8proc library.")

create_makefile("utf8_proc/utf8_proc")
