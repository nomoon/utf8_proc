
#include "utf8_proc.h"

const rb_encoding *enc_utf8;
const rb_encoding *enc_usascii;
ID NFC;
ID NFD;
ID NFKC;
ID NFKD;
ID NFKC_CF;

static inline void checkStrEncoding(VALUE *string) {
  rb_encoding *enc = rb_enc_get(*string);
  if (enc != enc_utf8 && enc != enc_usascii) {
    rb_raise(rb_eEncodingError, "%s", "String must be in UTF-8 or US-ASCII encoding.");
  }
}

static inline VALUE normInternal(VALUE string, utf8proc_option_t options) {
  checkStrEncoding(&string);
  utf8proc_uint8_t *retval;
  utf8proc_ssize_t retlen = utf8proc_map(
    (unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval, options);

  VALUE new_str = rb_enc_str_new((char *) retval, retlen, rb_utf8_encoding());
  free(retval);

  return new_str;
}


VALUE toNFC(VALUE self, VALUE string) {
  return normInternal(string, UTF8PROC_STABLE | UTF8PROC_COMPOSE);
}

VALUE toNFD(VALUE self, VALUE string) {
  return normInternal(string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE);
}

VALUE toNFKC(VALUE self, VALUE string) {
  return normInternal(string,UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT);
}

VALUE toNFKD(VALUE self, VALUE string) {
  return normInternal(string, UTF8PROC_STABLE | UTF8PROC_DECOMPOSE | UTF8PROC_COMPAT);
}

VALUE toNFKC_CF(VALUE self, VALUE string) {
  return normInternal(string, UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT | UTF8PROC_CASEFOLD);
}


VALUE norm(int argc, VALUE* argv, VALUE self){
  VALUE string;
  VALUE form;
  rb_scan_args(argc, argv, "11", &string, &form);

  if (NIL_P(form)) {
    return toNFC(self, string);
  }

  ID s_form = SYM2ID(form);
  if (s_form == NFC) {
    return toNFC(self, string);
  }else if(s_form == NFD) {
    return toNFD(self, string);
  }else if(s_form == NFKC) {
    return toNFKC(self, string);
  }else if(s_form == NFKD) {
    return toNFKD(self, string);
  }else if(s_form == NFKC_CF) {
    return toNFKC_CF(self, string);
  }else{
    rb_raise(rb_eArgError, "%s",
             "Second argument must be one of [:nfc (default), :nfd, :nfkc, " \
             ":nfkd, :nfkc_cf]");
  }
}

void Init_utf8_proc(void) {
  VALUE rb_mBase = rb_define_module("UTF8Proc");

  enc_utf8 = rb_utf8_encoding();
  enc_usascii = rb_usascii_encoding();
  NFC = rb_intern("nfc");
  NFD = rb_intern("nfd");
  NFKC = rb_intern("nfkc");
  NFKD = rb_intern("nfkd");
  NFKC_CF = rb_intern("nfkc_cf");

  rb_define_singleton_method(rb_mBase, "NFC", toNFC, 1);
  rb_define_singleton_method(rb_mBase, "NFD", toNFD, 1);
  rb_define_singleton_method(rb_mBase, "NFKC", toNFKC, 1);
  rb_define_singleton_method(rb_mBase, "NFKD", toNFKD, 1);
  rb_define_singleton_method(rb_mBase, "NFKC_CF", toNFKC_CF, 1);
  rb_define_singleton_method(rb_mBase, "normalize", norm, -1);
}
