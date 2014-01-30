#include <node.h>
#include <v8.h>
extern "C" {
	#include "handevaluator.h"
}

using namespace v8;

int cardToNumber(const char *card) {
	int value;
	switch (card[0]) {
	case 'T': value = 8;break;
	case 'J': value = 9;break;
	case 'Q': value = 10;break;
	case 'K': value = 11;break;
	case 'A': value = 12;break;
	default:
		value = card[0] - 0x32;
	}
	int suit;
	switch (card[1]) {
	case 'H': suit=0;break;
	case 'S': suit=1;break;
	case 'C': suit=2;break;
	case 'D': suit=3;break;
	}
	return (value*4)+suit;
}
Handle<Value> RankHands(const Arguments& args) {
	HandleScope scope;
	if (args.Length() < 2) {
		ThrowException(Exception::TypeError(String::New("wrong number of arguments")));
		return scope.Close(Undefined());
	}
	if (!args[0]->IsString()) {
		ThrowException(Exception::TypeError(String::New("first argument must be a string")));
		return scope.Close(Undefined());
	}
	if (!args[1]->IsArray()) {
		ThrowException(Exception::TypeError(String::New("second argument must be an array")));
		return scope.Close(Undefined());
	}
	Local<Object> root = Object::New();
	Local<Array> outputs = Array::New();
	root->Set(String::NewSymbol("outputs"),outputs);
	String::AsciiValue str(args[0]);
	const char *raw = *str;
	char cards[7];
	printf("string is '%s'\n",raw);
	for (int j=0; j<5; j++) {
		printf("%c%c\n",raw[j*2],raw[(j*2)+1]);
		cards[j] = cardToNumber(raw+(j*2));
	}
	root->Set(String::NewSymbol("input"),String::New(hand_to_str(cards,5)));
	Local<Array> hands = Local<Array>::Cast(args[1]);
	printf("hands %d\n",hands->Length());
	for (int j=0; j<hands->Length(); j++) {
		printf("ranking hand %s\n",hand_to_str(cards,7));
		Local<Value> item = hands->Get(j);
		if (!item->IsString()) {
			ThrowException(Exception::TypeError(String::New("second argument must be an array of strings")));
			return scope.Close(Undefined());
		}
		String::AsciiValue hole(item);
		raw = *hole;
		printf("hole: %s\n",raw);
		cards[5] = cardToNumber(raw);
		cards[6] = cardToNumber(raw+2);
		handeval_eq_class *rank = calculate_equivalence_class(cards);

		Local<Object> obj = Object::New();

		obj->Set(String::NewSymbol("id"),Number::New(rank->id));
		obj->Set(String::NewSymbol("desc"),String::New(rank->desc));
		obj->Set(String::NewSymbol("domination"),Number::New(rank->domination));
		obj->Set(String::NewSymbol("likelihood"),Number::New(rank->likelihood));
		obj->Set(String::NewSymbol("cards"),String::New(rank->cards));
		obj->Set(String::NewSymbol("input"),String::New(hand_to_str(cards+5,2)));
		outputs->Set(j,obj);
	}
	return scope.Close(root);
}
Handle<Value> InitDag(const Arguments& args) {
	HandleScope scope;
	handeval_init();
	return scope.Close(Undefined());
}
void init(Handle<Object> exports) {
	exports->Set(String::NewSymbol("rankHands"),FunctionTemplate::New(RankHands)->GetFunction());
	exports->Set(String::NewSymbol("init"),FunctionTemplate::New(InitDag)->GetFunction());
}

NODE_MODULE(dag,init)
