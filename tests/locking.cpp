#include <pthread.h>
#include <openssl/ssl.h>

#include "locking.h"

// https://curl.haxx.se/libcurl/c/opensslthreadlock.html
// http://stackoverflow.com/questions/3919420/tutorial-on-using-openssl-with-pthreads

static pthread_mutex_t * mutex_buf = NULL;

static void locking_function(int mode, int n, const char *file, int line) {
  //printf("locking %d\t%d\t%s:%d\n", mode, n, file, line);
  if (mode & CRYPTO_LOCK) pthread_mutex_lock(&mutex_buf[n]);
  else pthread_mutex_unlock(&mutex_buf[n]);
}

void thread_setup() {
  int i;

  mutex_buf = new pthread_mutex_t[CRYPTO_num_locks()];
  if (!mutex_buf) abort();

  for (i=0; i < CRYPTO_num_locks(); i++) {
    if (pthread_mutex_init(&mutex_buf[i], NULL) != 0) abort();
  }
  CRYPTO_set_locking_callback(locking_function);
}

void thread_cleanup() {
  int i;

  if (!mutex_buf) return;

  CRYPTO_set_locking_callback(NULL);
  for (i=0; i<CRYPTO_num_locks(); i++) {
    pthread_mutex_destroy(&mutex_buf[i]);
  }
  delete [] mutex_buf;
  mutex_buf = NULL;
}
