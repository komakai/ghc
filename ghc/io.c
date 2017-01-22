
#include "io.h"
#include <stdio.h>

char buffer[256];

#ifdef NATIVE_INPUT
#include "nativeint/native.h"

char* get_input(char* strStatus)
{
    return native_get_input(strStatus);
}

#else

#ifdef ANDROID

#define NEWLINE '\n'
#define NULLCHAR '\0'

ssize_t getline(char **pLine, size_t *pSize, FILE *pStream)
{
	return getDelimiter(pLine, pSize, NEWLINE, pStream);
}

#define DEFAULT_LINE_LENGTH 128
#define ERROR -1

ssize_t getDelimiter(char **pstrLine, size_t *pnSize, int cDelimiter, FILE *pStream)
{
	int nIndex = 0;
	int chr;

	if (pstrLine == NULL || pnSize == NULL || pStream == NULL) {
		return ERROR;
	}

	if (*pstrLine == NULL) {
		*pstrLine = malloc(DEFAULT_LINE_LENGTH);
		if (*pstrLine == NULL) {
			return ERROR;
		}
		*pnSize = DEFAULT_LINE_LENGTH;
	}

	while ((chr = getc(pStream)) != EOF) {
		if (nIndex >= *pnSize) {
			*pstrLine = realloc(*pstrLine, *pnSize + DEFAULT_LINE_LENGTH);
			if (*pstrLine == NULL) {
				return ERROR;
			}
			*pnSize += DEFAULT_LINE_LENGTH;
		}
		(*pstrLine)[nIndex++] = chr;

		if (chr == cDelimiter) {
			break;
		}
	}

	if (nIndex >= *pnSize)
	{
		*pstrLine = realloc(*pstrLine, *pnSize + DEFAULT_LINE_LENGTH);
		if (*pstrLine == NULL) {
			return ERROR;
		}
		*pnSize += DEFAULT_LINE_LENGTH;
	}

	(*pstrLine)[nIndex++] = NULLCHAR;

	return (chr == EOF && (nIndex - 1) == 0) ? ERROR : (nIndex - 1);
}

#endif

char* get_input( char* strStatus )
{
	size_t n = sizeof(buffer);
	char* qbuffer = buffer;
	getline(&qbuffer, &n, stdin);
	return buffer;
}

#endif
