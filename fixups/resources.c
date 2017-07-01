
#include <stdlib.h>
#include <string.h>
#include "resources.h"

typedef struct {
	char* filename;
	char* resource;
	unsigned long size;
} resTableEntry;

#ifdef DYNAMIC
#include "resfiles.dyn_inc"
#else
#include "resfiles.inc"
#endif

static int g_bResInit = 0;

static resTableEntry* lookupEntry(char* strEntry)
{
	if ( strEntry[0] == '.' && strEntry[1] == '/' ) {
		strEntry += 2;
	}
	int lo=0,hi=FILENUM,mid,cmp; //from resfiles.c
	if (!g_bResInit) {
		initResTable();
		g_bResInit=1;
	}
	while (lo<hi) {
		mid = (lo+hi)/2;
		cmp = strcmp(strEntry,g_resources[mid].filename);
		if (cmp==0) {
			return &g_resources[mid];
		} else if (cmp>0) {
			if (lo==mid) break;
			lo = mid;
		} else if (cmp<0) {
			if (hi==mid) break;
			hi = mid;
		}
	}
	return NULL;
}

int getLen(char* strName)
{
	resTableEntry* pEntry = lookupEntry(strName);
	return (pEntry!=NULL)?pEntry->size:0;
}

char* getContent(char* strName)
{
	resTableEntry* pEntry = lookupEntry(strName);
	return (pEntry!=NULL)?pEntry->resource:NULL;
}

void finalizerNull(void* p)
{
	return;
}

