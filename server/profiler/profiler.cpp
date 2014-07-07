#include <node.h>
#include <v8.h>

using namespace v8;

Handle<Value> getCpuTime(const Arguments& args) {
	HandleScope scope;
	struct timespec tp;
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&tp);
	Local<Object> tp2 = Object::New();
	tp2->Set(String::NewSymbol("tv_sec"),Number::New(tp.tv_sec));
	tp2->Set(String::NewSymbol("tv_nsec"),Number::New(tp.tv_nsec));
	return scope.Close(tp2);
}
Handle<Value> getThreadTime(const Arguments& args) {
	HandleScope scope;
	struct timespec tp;
	clock_gettime(CLOCK_THREAD_CPUTIME_ID,&tp);
	Local<Object> tp2 = Object::New();
	tp2->Set(String::NewSymbol("tv_sec"),Number::New(tp.tv_sec));
	tp2->Set(String::NewSymbol("tv_nsec"),Number::New(tp.tv_nsec));
	return scope.Close(tp2);
}
void init(Handle<Object> exports) {
	exports->Set(String::NewSymbol("getCpuTime"),FunctionTemplate::New(getCpuTime)->GetFunction());
	exports->Set(String::NewSymbol("getThreadTime"),FunctionTemplate::New(getThreadTime)->GetFunction());
}

NODE_MODULE(profile_util,init);
