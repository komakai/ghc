
/* kick-off the haskell runtime */
void runHaskell();

/* get redirected input from stdout or stderr */
void nativePipeRedirect(char* buffer, int buflen, int redirectId, int createPipe);

/* send signal interrupt to ourselves (handle STOP button) */
void interrupt();
