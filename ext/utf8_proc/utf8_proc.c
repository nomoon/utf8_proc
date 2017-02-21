
#include "utf8_proc.h"

const rb_encoding *enc_utf8;
const rb_encoding *enc_usascii;
ID NFC;
ID NFD;
ID NFKC;
ID NFKD;

void checkStrEncoding(VALUE *string) {
  rb_encoding *enc = rb_enc_get(*string);
  if (enc != enc_utf8 && enc != enc_usascii) {
    rb_raise(rb_eRuntimeError, "%s", "String must be in UTF-8 or US-ASCII encoding.");
  }
}

VALUE CtoNFC(VALUE self, VALUE string) {
  checkStrEncoding(&string);
  utf8proc_uint8_t *retval;
  utf8proc_ssize_t retlen = utf8proc_map(
    (unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval,
    UTF8PROC_STABLE | UTF8PROC_COMPOSE);

  VALUE new_str = rb_enc_str_new((char *) retval, retlen, rb_utf8_encoding());
  free(retval);

  return new_str;
}

VALUE CtoNFD(VALUE self, VALUE string) {
  checkStrEncoding(&string);
  utf8proc_uint8_t *retval;
  utf8proc_ssize_t retlen = utf8proc_map(
    (unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval,
    UTF8PROC_STABLE | UTF8PROC_DECOMPOSE);

  VALUE new_str = rb_enc_str_new((char *) retval, retlen, rb_utf8_encoding());
  free(retval);

  return new_str;
}

VALUE CtoNFKC(VALUE self, VALUE string) {
  checkStrEncoding(&string);
  utf8proc_uint8_t *retval;
  utf8proc_ssize_t retlen = utf8proc_map(
    (unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval,
    UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT);

  VALUE new_str = rb_enc_str_new((char *) retval, retlen, rb_utf8_encoding());
  free(retval);

  return new_str;
}

VALUE CtoNFKD(VALUE self, VALUE string) {
  checkStrEncoding(&string);
  utf8proc_uint8_t *retval;
  utf8proc_ssize_t retlen = utf8proc_map(
    (unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval,
    UTF8PROC_STABLE | UTF8PROC_DECOMPOSE | UTF8PROC_COMPAT);

  VALUE new_str = rb_enc_str_new((char *) retval, retlen, rb_utf8_encoding());
  free(retval);

  return new_str;
}

VALUE Cnorm(int argc, VALUE* argv, VALUE self){
  VALUE string;
  VALUE form;
  rb_scan_args(argc, argv, "11", &string, &form);

  if (NIL_P(form)) {
    return CtoNFC(self, string);
  }

  ID s_form = SYM2ID(form);
  if (s_form == NFC) {
    return CtoNFC(self, string);
  }else if(s_form == NFD) {
    return CtoNFD(self, string);
  }else if(s_form == NFKC) {
    return CtoNFKC(self, string);
  }else if(s_form == NFKD) {
    return CtoNFKD(self, string);
  }else{
    rb_raise(rb_eRuntimeError, "%s",
             "Second optional argument must be one of [:nfc, :nfd, :nfkc, :nfkd] (defaults to :nfc)");
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

  rb_define_singleton_method(rb_mBase, "to_NFC", CtoNFC, 1);
  rb_define_singleton_method(rb_mBase, "to_NFD", CtoNFD, 1);
  rb_define_singleton_method(rb_mBase, "to_NFKC", CtoNFKC, 1);
  rb_define_singleton_method(rb_mBase, "to_NFKD", CtoNFKD, 1);
  rb_define_singleton_method(rb_mBase, "normalize", Cnorm, -1);
}
