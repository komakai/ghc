#ifndef __MINGW32__

#include "HsBase.h"

#include <stdlib.h>
#if defined(HAVE_LIBICONV)
#include <iconv.h>
#else
typedef void* iconv_t;
#endif

iconv_t hs_iconv_open(const char* tocode,
		      const char* fromcode)
{
#if defined(HAVE_LIBICONV)
    return iconv_open(tocode, fromcode);
#else
    return (iconv_t)-1;
#endif
}

size_t hs_iconv(iconv_t cd,
		const char* * inbuf, size_t * inbytesleft,
		char* * outbuf, size_t * outbytesleft)
{
#if defined(HAVE_LIBICONV)
     // (void*) cast avoids a warning.  Some iconvs use (const
     // char**inbuf), other use (char **inbuf).
     return iconv(cd, (void*)inbuf, inbytesleft, outbuf, outbytesleft);
#else
    return (size_t)-1;
#endif
}

int hs_iconv_close(iconv_t cd) {
#if defined(HAVE_LIBICONV)
    return iconv_close(cd);
#else
    return -1;
#endif
}

#endif
