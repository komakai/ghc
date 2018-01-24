
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#include "HsBase.h"

#ifdef INTERACTIVE_EDITION

#define BUFFER_SIZE 10000

typedef struct {
	unsigned char buffer[BUFFER_SIZE];
	int start;
	int length;
	int overflowed;
	pthread_mutex_t lock;
} ioBuffer;

static ioBuffer stdOutBuffer;
static ioBuffer stdErrBuffer;

static void initBuffer(ioBuffer* buf)
{
	buf->start = 0;
	buf->length = 0;
	buf-> overflowed = 0;
	if (pthread_mutex_init(&buf->lock, NULL) != 0)
	{
		printf("\n mutex init failed\n");
	}
}

static void deinitBuffer(ioBuffer* buf)
{
	pthread_mutex_destroy(&buf->lock);
}

void initBuffers()
{
	initBuffer(&stdOutBuffer);
	initBuffer(&stdErrBuffer);
}

void deinitBuffers()
{
	deinitBuffer(&stdOutBuffer);
	deinitBuffer(&stdErrBuffer);
}

static int isControlChar(unsigned char c)
{
	int ret=0;
	if (c<0x20) {
		if (c!='\n' && c!='\r' && c!='\t') {
			ret=1;
		}
	}
	if (c==0x7F || c==0x81 || c==0x8F || c==0x90 || c==0x9D) {
		ret=1;
	}
	return ret;
}

#define HI_NIBBLE(x) (x)/16
#define LO_NIBBLE(x) (x)%16
#define TO_HEX(x) ((x)<=9?('0'+(x)):('A'+(x)-10))

static void getBufferLenAndCopy(ioBuffer* buf, char* outBuffer, int* size)
{
	int i,j=0;
	for (i=0;i<buf->length;i++) {
		int controlChar = isControlChar(buf->buffer[(buf->start+i)%BUFFER_SIZE]);
		if (size) {
			*size += controlChar?4:1;
		}
		if (outBuffer) {
			char currChar=buf->buffer[(buf->start+i)%BUFFER_SIZE];
			if (controlChar) {
				outBuffer[j++] = '\\';
				outBuffer[j++] = 'x';
				outBuffer[j++] = TO_HEX(HI_NIBBLE(currChar));
				outBuffer[j++] = TO_HEX(LO_NIBBLE(currChar));
			} else {
				outBuffer[j++] = currChar;
			}
		}
	}
}

static char* getAndClearBuffer(ioBuffer* buf)
{
	int outlen=0;
	char* result;
	pthread_mutex_lock(&buf->lock);
	getBufferLenAndCopy(buf, NULL, &outlen);
	result = malloc(outlen+1);
	if (result==NULL) goto cleanup;
	getBufferLenAndCopy(buf, result, NULL);
	result[outlen] = '\0';
	buf->start = 0;
	buf->length = 0;
	buf->overflowed = 0;
cleanup:
	pthread_mutex_unlock(&buf->lock);
	return result;
}

char* getAndClearStdOut()
{
	return getAndClearBuffer(&stdOutBuffer);
}

char* getAndClearStdErr()
{
	return getAndClearBuffer(&stdErrBuffer);
}
#endif /* INTERACTIVE_EDITION */

ssize_t hs_write(int fd, const void *buf, size_t count)
{
#ifdef INTERACTIVE_EDITION
	if (fd==STDOUT_FILENO || fd==STDERR_FILENO) {
		ioBuffer* iobuf = (fd==STDOUT_FILENO)?&stdOutBuffer:&stdErrBuffer;
		pthread_mutex_lock(&iobuf->lock);
		int writeOffset = (iobuf->start+iobuf->length)%BUFFER_SIZE;
		if (writeOffset+count<=BUFFER_SIZE) {
			memcpy(iobuf->buffer+writeOffset, buf, count);
			if (iobuf->length+count<=BUFFER_SIZE) {
				iobuf->length += count;
			} //otherwise we must have already overflowed and length will already be BUFFER_SIZE
		} else {
			iobuf->overflowed = 1;
			memcpy(iobuf->buffer+writeOffset, buf, BUFFER_SIZE-writeOffset);
			memcpy(iobuf->buffer, buf+(BUFFER_SIZE-writeOffset), count-(BUFFER_SIZE-writeOffset));
			iobuf->start = (BUFFER_SIZE-writeOffset);
			iobuf->length = BUFFER_SIZE;
		}
		pthread_mutex_unlock(&iobuf->lock);
	}
#endif /* INTERACTIVE_EDITION */
	return write(fd, buf, count);
}


