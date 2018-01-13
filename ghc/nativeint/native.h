
#define DBUG  0
#define INFO  1
#define WARN  2
#define ERROR 3
#define FATAL 4

typedef void (*log_fn)(int, const char*);
typedef const char* (*get_input_fn)(const char*);

extern log_fn native_log;
extern get_input_fn native_get_input;

void* native_backup_bss();

void native_restore_bss(void* pBack);

