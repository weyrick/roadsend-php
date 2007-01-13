#define MAXPACKET 8192

int php_checkdnsrr(char *host, char *typestr);
int php_getprotobyname(char *name);
int php_getservbyname(char *name, char *protocol);
long php_ip2long(char *ip_address);
int php_getmxrr(char *hostname, char *mx_list, char *weight_list);
int php_fsockopen(char *hostname, int port, int domain, int type, int *errno_p, char **errstr_p);




