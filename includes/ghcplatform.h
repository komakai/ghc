#if STAGE==1
#include "stage1/ghcplatform.h"
#elif STAGE==2
#include "stage2/ghcplatform.h"
#else
#error "Invalid STAGE !!!"
#endif

