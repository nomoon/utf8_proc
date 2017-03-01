
#include "utf8_proc.h"

static rb_encoding *enc_utf8;
static rb_encoding *enc_usascii;
static ID NFC;
static ID NFD;
static ID NFKC;
static ID NFKD;
static ID NFKC_CF;

// Derived from utf8proc_map_custom.
// Pre-allocates string buffers and skips initial preflight decompose and
// post-flight relloc for speed.
static inline VALUE normInternal(VALUE *string, utf8proc_option_t options) {
  rb_encoding *enc;
  enc = rb_enc_get(*string);
  if (!(enc == enc_utf8 || enc == enc_usascii)) {
    rb_raise(rb_eEncodingError, "%s", "String must be in UTF-8 or US-ASCII encoding.");
  }

  // Allocate buffer to safe maximum length estimated from Normalization options
  // and known maximal expansion of codepoints
  utf8proc_int32_t *buffer;
  utf8proc_ssize_t bufflen;
  bufflen = rb_str_strlen(*string) * ((options & UTF8PROC_COMPAT) ? 18 : 4);
  buffer = (utf8proc_int32_t *) malloc(bufflen * sizeof(utf8proc_int32_t) + 1);
  if (!buffer) {
    rb_raise(rb_eEncodingError, "%s", utf8proc_errmsg(UTF8PROC_ERROR_NOMEM));
    return Qnil;
  }

  utf8proc_ssize_t result;
  // Decompose input
  result = utf8proc_decompose_custom((unsigned char *) StringValuePtr(*string),
                                     RSTRING_LEN(*string), buffer, bufflen,
                                     options, NULL, NULL);
  if (result < 0) {
    free(buffer);
    rb_raise(rb_eEncodingError, "%s", utf8proc_errmsg(result));
    return Qnil;
  }

  // Compose & re-encode input.
  result = utf8proc_reencode(buffer, result, options);
  if (result < 0) {
    free(buffer);
    rb_raise(rb_eEncodingError, "%s", utf8proc_errmsg(result));
    return Qnil;
  }

  VALUE new_str;
  new_str = rb_enc_str_new((char *) buffer, result, enc_utf8);
  free(buffer);
  return new_str;
}

// NFC

static VALUE toNFC(VALUE self, VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE);
}

static VALUE StoNFC(VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE);
}

// NFD

static VALUE toNFD(VALUE self, VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE);
}

static VALUE StoNFD(VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE);
}

// NFKC

static VALUE toNFKC(VALUE self, VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT);
}

static VALUE StoNFKC(VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT);
}

// NFKD

static VALUE toNFKD(VALUE self, VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE | UTF8PROC_COMPAT);
}

static VALUE StoNFKD(VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE | UTF8PROC_COMPAT);
}

// NFKC_CF

static VALUE toNFKC_CF(VALUE self, VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT | UTF8PROC_CASEFOLD);
}

static VALUE StoNFKC_CF(VALUE string) {
  return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT | UTF8PROC_CASEFOLD);
}

// Parameterized normalization

static VALUE toNorm(int argc, VALUE* argv, VALUE self){
  VALUE string;
  VALUE form;
  rb_scan_args(argc, argv, "11", &string, &form);

  if (NIL_P(form)) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE);
  }

  ID s_form;
  s_form = SYM2ID(form);
  if (s_form == NFC) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE);
  } else if (s_form == NFD) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE);
  } else if (s_form == NFKC) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT);
  } else if (s_form == NFKD) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE | UTF8PROC_COMPAT);
  } else if (s_form == NFKC_CF) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT | UTF8PROC_CASEFOLD);
  } else {
    rb_raise(rb_eArgError, "%s",
             "Second argument must be one of [:nfc (default), :nfd, :nfkc, " \
             ":nfkd, :nfkc_cf]");
  }
}

static VALUE StoNorm(int argc, VALUE* argv, VALUE string){
  VALUE form;
  rb_scan_args(argc, argv, "01", &form);

  if (NIL_P(form)) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE);
  }

  ID s_form;
  s_form = SYM2ID(form);
  if (s_form == NFC) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE);
  } else if (s_form == NFD) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE);
  } else if (s_form == NFKC) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT);
  } else if (s_form == NFKD) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE | UTF8PROC_COMPAT);
  } else if (s_form == NFKC_CF) {
    return normInternal(&string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT | UTF8PROC_CASEFOLD);
  } else {
    rb_raise(rb_eArgError, "%s",
             "Argument must be one of [:nfc (default), :nfd, :nfkc, " \
             ":nfkd, :nfkc_cf]");
  }
}

void Init_utf8_proc(void) {
  VALUE rb_mBase;
  rb_mBase = rb_define_module("UTF8Proc");

  enc_utf8 = rb_utf8_encoding();
  enc_usascii = rb_usascii_encoding();
  NFC = rb_intern("nfc");
  NFD = rb_intern("nfd");
  NFKC = rb_intern("nfkc");
  NFKD = rb_intern("nfkd");
  NFKC_CF = rb_intern("nfkc_cf");

  const char *libVersion;
  libVersion = utf8proc_version();
  rb_define_const(rb_mBase, "LIBRARY_VERSION", rb_str_freeze(
    rb_enc_str_new(libVersion, strlen(libVersion), enc_utf8)
  ));

  rb_define_singleton_method(rb_mBase, "NFC", toNFC, 1);
  rb_define_singleton_method(rb_mBase, "NFD", toNFD, 1);
  rb_define_singleton_method(rb_mBase, "NFKC", toNFKC, 1);
  rb_define_singleton_method(rb_mBase, "NFKD", toNFKD, 1);
  rb_define_singleton_method(rb_mBase, "NFKC_CF", toNFKC_CF, 1);
  rb_define_singleton_method(rb_mBase, "normalize", toNorm, -1);

  VALUE rb_mStringExt;
  rb_mStringExt = rb_define_module_under(rb_mBase, "StringExtension");
  rb_define_method(rb_mStringExt, "NFC", StoNFC, 0);
  rb_define_method(rb_mStringExt, "NFD", StoNFD, 0);
  rb_define_method(rb_mStringExt, "NFKC", StoNFKC, 0);
  rb_define_method(rb_mStringExt, "NFKD", StoNFKD, 0);
  rb_define_method(rb_mStringExt, "NFKC_CF", StoNFKC_CF, 0);
  rb_define_method(rb_mStringExt, "normalize", StoNorm, -1);
}
