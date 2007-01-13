
#include "sqlite3.h"

int sqlite_custom_function(sqlite3* db, char* sqlite_name, char* php_name, int num_args);
int sqlite_custom_aggregate(sqlite3* db, char* sqlite_name, obj_t user_data, int num_args);
