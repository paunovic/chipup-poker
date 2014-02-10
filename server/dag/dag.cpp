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
int cardToNumber(Local<Array> cards,int index) {
	int value = cards->Get(index)->Int32Value();
	return value;
}
Local<Array> getCards(Local<Object> game,const char *field) {
	return Local<Array>::Cast(game->Get(String::NewSymbol(field))->ToObject()->Get(String::NewSymbol("cards")));
}
Handle<Value> RankHands(const Arguments& args) {
	HandleScope scope;
	char cards[7];
	if (args.Length() < 2) {
		ThrowException(Exception::TypeError(String::New("wrong number of arguments")));
		return scope.Close(Undefined());
	}
	if (!args[0]->IsObject()) {
		ThrowException(Exception::TypeError(String::New("first argument must be a Game")));
		return scope.Close(Undefined());
	}
	if (!args[1]->IsArray()) {
		ThrowException(Exception::TypeError(String::New("second argument must be an array")));
		return scope.Close(Undefined());
	}
	Local<Object> root = Object::New();
	Local<Array> outputs = Array::New();
	root->Set(String::NewSymbol("outputs"),outputs);

	Local<Object> game = args[0]->ToObject();
	Local<Array> flop = getCards(game,"flop");
	if (flop->Length() != 3) {
		ThrowException(Exception::TypeError(String::New("first argument must be a array of 3 Cards")));
		return scope.Close(Undefined());
	}
	cards[0] = cardToNumber(flop,0);
	cards[1] = cardToNumber(flop,1);
	cards[2] = cardToNumber(flop,2);
	cards[3] = cardToNumber(getCards(game,"turn"),0);
	cards[4] = cardToNumber(getCards(game,"river"),0);
	root->Set(String::NewSymbol("input"),String::New(hand_to_str(cards,5)));
	Local<Array> hands = Local<Array>::Cast(args[1]);
	for (unsigned int j=0; j<hands->Length(); j++) {
		Local<Value> item = hands->Get(j);
		if (!item->IsObject()) {
			ThrowException(Exception::TypeError(String::New("second argument must be an array of strings")));
			return scope.Close(Undefined());
		}
		Local<Object> hand = item->ToObject();
		Local<Array> cardlist = Local<Array>::Cast(hand->Get(String::NewSymbol("hand"))); // array of Card objects
		
		cards[5] = cardToNumber(cardlist,0);
		cards[6] = cardToNumber(cardlist,1);
		printf("ranking hand %s + %s\n",hand_to_str(cards,5),hand_to_str(cards+5,2));
		handeval_eq_class *rank = calculate_equivalence_class(cards);

		hand->Set(String::NewSymbol("id"),Number::New(rank->id));
		hand->Set(String::NewSymbol("desc"),String::New(rank->desc));
		hand->Set(String::NewSymbol("domination"),Number::New(rank->domination));
		hand->Set(String::NewSymbol("likelihood"),Number::New(rank->likelihood));
		hand->Set(String::NewSymbol("cards"),String::New(rank->cards));
		hand->Set(String::NewSymbol("input"),String::New(hand_to_str(cards+5,2)));
		outputs->Set(j,hand);
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
