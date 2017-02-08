#include <node.h>
#include <v8.h>
#include <time.h>

using namespace v8;

void getCpuTime(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    struct timespec tp;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&tp);
    Local<Object> tp2 = Object::New(isolate);
    tp2->Set(String::NewFromUtf8(isolate, "tv_sec"), Number::New(isolate, tp.tv_sec));
    tp2->Set(String::NewFromUtf8(isolate, "tv_nsec"), Number::New(isolate, tp.tv_nsec));
    args.GetReturnValue().Set(tp2);
}
void getThreadTime(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    struct timespec tp;
    clock_gettime(CLOCK_THREAD_CPUTIME_ID,&tp);
    Local<Object> tp2 = Object::New(isolate);
    tp2->Set(String::NewFromUtf8(isolate, "tv_sec"), Number::New(isolate, tp.tv_sec));
    tp2->Set(String::NewFromUtf8(isolate, "tv_nsec"), Number::New(isolate, tp.tv_nsec));
    args.GetReturnValue().Set(tp2);
}
void getMonoTime(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    struct timespec tp;
    clock_gettime(CLOCK_MONOTONIC,&tp);
    Local<Object> tp2 = Object::New(isolate);
    tp2->Set(String::NewFromUtf8(isolate, "tv_sec"), Number::New(isolate, tp.tv_sec));
    tp2->Set(String::NewFromUtf8(isolate, "tv_nsec"), Number::New(isolate, tp.tv_nsec));
    args.GetReturnValue().Set(tp2);
}
void init(Handle<Object> exports) {
    NODE_SET_METHOD(exports, "getCpuTime", getCpuTime);
    NODE_SET_METHOD(exports, "getThreadTime", getThreadTime);
    NODE_SET_METHOD(exports, "getMonoTime", getMonoTime);
}

NODE_MODULE(profile_util,init);
