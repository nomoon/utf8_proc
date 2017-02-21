
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
  utf8proc_uint8_t *retval;
  checkStrEncoding(&string);
  utf8proc_map((unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval,
               UTF8PROC_NULLTERM | UTF8PROC_STABLE | UTF8PROC_COMPOSE);

  return rb_enc_str_new((char *) retval, strlen((char *)retval), rb_utf8_encoding());
}

VALUE CtoNFD(VALUE self, VALUE string) {
  utf8proc_uint8_t *retval;
  checkStrEncoding(&string);
  utf8proc_map((unsigned char *) StringValuePtr(string), RSTRING_LEN(string),
               &retval, UTF8PROC_NULLTERM | UTF8PROC_STABLE | UTF8PROC_DECOMPOSE);

  return rb_enc_str_new((char *) retval, strlen((char *)retval), rb_utf8_encoding());
}

VALUE CtoNFKC(VALUE self, VALUE string) {
  utf8proc_uint8_t *retval;
  checkStrEncoding(&string);
  utf8proc_map((unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval,
               UTF8PROC_NULLTERM | UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT);

  return rb_enc_str_new((char *) retval, strlen((char *)retval), rb_utf8_encoding());
}

VALUE CtoNFKD(VALUE self, VALUE string) {
  utf8proc_uint8_t *retval;
  checkStrEncoding(&string);
  utf8proc_map((unsigned char *) StringValuePtr(string), RSTRING_LEN(string), &retval,
               UTF8PROC_NULLTERM | UTF8PROC_STABLE | UTF8PROC_DECOMPOSE | UTF8PROC_COMPAT);

  return rb_enc_str_new((char *) retval, strlen((char *)retval), rb_utf8_encoding());
}

VALUE Cnorm(VALUE self, VALUE form, VALUE string){
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
             "First argument must be one of [:nfc, :nfd, :nfkc, :nfkd]");
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
  rb_define_singleton_method(rb_mBase, "normalize", Cnorm, 2);
}
