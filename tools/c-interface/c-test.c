/*

  The purpose of this file is to test the C interface
  to the Roadsend PHP runtime


 */

#include "re_runtime.h"

obj_t re_main(obj_t argv_cons)
{
  BGl_modulezd2initializa7ationz75zzrezd2czd2interfacez00(0, "c-test");
  BGl_bigloozd2initializa7edz12z67zz__paramz00();
}

int main(int argc, char *argv[], char *env[])
{
 
  _bigloo_main(argc, argv, env, &re_main);
  re_runtime_init();
  
  // php hash
  obj_t myhash = re_make_php_hash();
  re_php_hash_insert(myhash, "key1", "val1");
  re_php_hash_insert(myhash, "key2", "val2");
  re_var_dump(myhash);

}

