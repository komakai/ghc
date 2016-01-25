
#define DBUG  0
#define INFO  1
#define WARN  2
#define ERROR 3
#define FATAL 4

void native_log(int priority, char* msg);

char* native_get_input(char* strStatus);

void* native_backup_bss();

void native_restore_bss(void* pBack);

