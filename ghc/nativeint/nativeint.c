#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "Rts.h"
#include "nativeint.h"
#include "native.h"

extern StgClosure ghczmlibzm7zi8zi3_Main_main_closure;

extern void initBuffers();
extern void deinitBuffers();

extern int hs_main(int argc, char* argv[], StgClosure* main_closure, RtsConfig rts_config);

extern int __bss_start;
extern int _end;

FILE *redirectPipe[2]={NULL,NULL};

void runHaskell()
{
	int argc=3;
	char* strExe=strdup("dummy");
	char* strTopdir=strdup("-B");
	char* strInteractive=strdup("--interactive");
	char* argv[] = {strExe, strTopdir, strInteractive};
	char* strRtsOpts = strdup("-V0");
	RtsConfig rtsConfig = { RtsOptsNone, strRtsOpts, rtsFalse };

	native_log(INFO, "In runHaskell");
	initBuffers();
	native_log(INFO, "Calling hs_main");
	hs_main(argc, argv, &ghczmlibzm7zi8zi3_Main_main_closure, rtsConfig);
	deinitBuffers();
	native_log(INFO, "Returned from hs_main");
	free(strExe);
	free(strTopdir);
	free(strInteractive);
	free(strRtsOpts);
	if (redirectPipe[0]!=NULL) {
		fclose(redirectPipe[0]);
		redirectPipe[0]=NULL;
	}
	if (redirectPipe[1]!=NULL) {
		fclose(redirectPipe[1]);
		redirectPipe[1]=NULL;
	}
#ifdef __PIC__
	void* bssBackup = native_backup_bss();
	memset((void*)__bss_start, 0 , _end-__bss_start);
	native_restore_bss(bssBackup);
#endif
	native_log(INFO, "Returning from runHaskell");
}

void nativePipeRedirect(char* buffer, int buflen, int fileId, int createPipe)
{
	int redirectId = fileId-1;
	native_log(INFO,"In nativePipeRedirect");
	if (createPipe) {
		//tidy-up any unclosed pipes from a previos run
		if (redirectPipe[redirectId]!=NULL) {
			fclose(redirectPipe[redirectId]);
		}
		int pipes[2];
		if (pipe(pipes)==-1) {
			native_log(ERROR, "pipe failed");
		}
		if (dup2(pipes[1], fileId)==-1) {
			native_log(ERROR, "dup2 failed");
		}
		if ((redirectPipe[redirectId] = fdopen(pipes[0], "r"))==NULL) {
			native_log(ERROR, "fdopen failed");
		}
	}
	native_log(INFO, "calling fgets from nativePipeRedirect");
	if (redirectPipe[redirectId]!=NULL) {
		fgets(buffer, buflen, redirectPipe[redirectId]);
		native_log(INFO, "fgets returned to nativePipeRedirect");
	} else {
		native_log(INFO, "pipe gone - skipped call to fgets");
	}
	if (redirectPipe[redirectId]==NULL) {
		native_log(INFO, "pipe gone - nativePipeRedirect returning empty string");
		buffer[0] = '\0';
	}

	native_log(INFO,"Returning from nativePipeRedirect");
}

void interrupt()
{
	raise(SIGINT);
}
