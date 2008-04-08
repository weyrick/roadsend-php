/*

  The purpose of this file is to test the C interface
  to the Roadsend PHP runtime


 */

#include "re_runtime.h"

int main(void) {

  BGl_modulezd2initializa7ationz75zzrezd2czd2interfacez00(0, "c-test");

  // php hash
  obj_t myhash = re_make_php_hash();
  re_php_hash_insert(myhash, "key1", "val1");
  re_php_hash_insert(myhash, "key2", "val2");

}

