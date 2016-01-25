#include <jni.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <android/log.h>
#include "../nativeint.h"
#include "../native.h"
#include "haskell-jni.h"
#include "Rts.h"

jobject g_HaskellActivity=NULL;
JavaVM* g_vm=NULL;

#define LOAD_COMMAND 0
#define RELOAD_COMMAND 1
#define BREAKMAIN_COMMAND 2
#define RUN_COMMAND 3
#define STEP_COMMAND 4
#define RESUME_COMMAND 5
#define EXIT_COMMAND 6

char* g_strCommands[] = {":load /data/data/jp.alpha/files/main.hs",":reload",":break main","main",":step",":continue",":exit"};

int convert_priority(int priority)
{
	int converted_priority;
	switch (priority)
	{
		case DBUG:
			converted_priority = ANDROID_LOG_DEBUG;
			break;
		case INFO:
			converted_priority = ANDROID_LOG_INFO;
			break;
		case WARN:
			converted_priority = ANDROID_LOG_WARN;
			break;
		case ERROR:
			converted_priority = ANDROID_LOG_ERROR;
			break;
		case FATAL:
			converted_priority = ANDROID_LOG_FATAL;
			break;
		default:
			converted_priority = ANDROID_LOG_DEFAULT;
			break;
	}
	return converted_priority;
}

void native_log(int priority, char* msg)
{
	int android_priority = convert_priority(priority);
	__android_log_write(android_priority, "Haskell", msg);
}

extern char* getAndClearStdOut();
extern char* getAndClearStdErr();

char* native_get_input(char* strStatus)
{
	char* strRet=NULL;

	if (g_vm) {
		JNIEnv* env=NULL;
		(*g_vm)->AttachCurrentThread(g_vm, &env, NULL);
		if (env) {
			jclass activityClass = (*env)->GetObjectClass(env, g_HaskellActivity);
			jmethodID getNextActionId = (*env)->GetMethodID(env, activityClass, "getNextAction", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;");
			char* stdOutBuffer = getAndClearStdOut();
			native_log(INFO, stdOutBuffer);
			char* stdErrBuffer = getAndClearStdErr();
			native_log(INFO, stdErrBuffer);
			jstring status = (*env)->NewStringUTF(env, strStatus);
			jstring out = (*env)->NewStringUTF(env, stdOutBuffer);
			jstring err = (*env)->NewStringUTF(env, stdErrBuffer);
			native_log(INFO, "Calling getNextAction");
			jstring nextActionResult = (jstring)(*env)->CallObjectMethod(env, g_HaskellActivity, getNextActionId,status,out,err);
			native_log(INFO, "Returned from getNextAction");
			const char* strNextAction = (*env)->GetStringUTFChars(env, nextActionResult, NULL);
			strRet=g_strCommands[atoi(strNextAction)];
			(*env)->ReleaseStringUTFChars(env, nextActionResult, strNextAction);
			free(stdOutBuffer);
			free(stdErrBuffer);
		}
	}

	return strRet;
}

void* native_backup_bss()
{
	void *pBack = malloc( sizeof(g_vm) );
	*(JavaVM*)pBack = g_vm;
	return pBack;
}

void native_restore_bss(void* pBack)
{
	g_vm = *(JavaVM*)pBack;
	free(pBack);
}

void Java_jp_alpha_HaskellActivity_runHaskell(JNIEnv* env, jobject thiz)
{
	g_HaskellActivity=thiz;
	runHaskell();
}


void Java_jp_alpha_HaskellActivity_interrupt(JNIEnv* env, jobject thiz)
{
	interrupt();
}

jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
	JNIEnv* env;
	native_log(INFO, "Entering JNI_OnLoad");

	if (!vm || !(*vm)) {
		return -1;
	}
	if ((*vm)->GetEnv(vm,(void**)&env, JNI_VERSION_1_6) != JNI_OK) {
		return -1;
	}
	native_log(INFO, "Leaving JNI_OnLoad");
	g_vm=vm;
	return JNI_VERSION_1_6;
}

#define BUFFER_LEN 256

static jstring nativePipe(JNIEnv* env, int fileId, int createPipe)
{
	char buffer[BUFFER_LEN];
	nativePipeRedirect(buffer, BUFFER_LEN, fileId, createPipe);
	return (*env)->NewStringUTF(env, buffer);
}

jstring Java_jp_alpha_HaskellActivity_nativePipeStdout(JNIEnv* env, jobject thiz, jboolean createPipe)
{
	return nativePipe(env, STDOUT_FILENO, (createPipe == JNI_TRUE));
}

jstring Java_jp_alpha_HaskellActivity_nativePipeStderr(JNIEnv* env, jobject thiz, jboolean createPipe)
{
	return nativePipe(env, STDERR_FILENO, (createPipe == JNI_TRUE));
}
