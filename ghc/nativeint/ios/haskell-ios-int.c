#include <stdlib.h>
#include <stdio.h>
#include "../native.h"

#if defined(HAVE_BSS_LIMITS)
#include "../bss_limits.h"

void* __bss_start = (void*) BSS_START;
void* _end = (void*) BSS_END;
#else
// dummy values
void* __bss_start = (void*)0x10000000;
void* _end = (void*)0x10000000;
#endif

get_input_fn native_get_input = NULL;

void* native_backup_bss()
{
    void *pBack = malloc( sizeof(get_input_fn) );
    *(get_input_fn*)pBack = native_get_input;
    return pBack;
}

void native_restore_bss(void* pBack)
{
    native_get_input = *(get_input_fn*)pBack;
    free(pBack);
}

void native_log_default(int priority, const char* msg) {
    printf("%s\n", msg);
}

log_fn native_log = native_log_default;

void set_native_log_fn(log_fn fn) {
    native_log = fn;
}

void set_native_get_input_fn(get_input_fn fn) {
    native_get_input = fn;
}
