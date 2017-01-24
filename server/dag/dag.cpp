#include <node.h>
#include <v8.h>
extern "C" {
	#include "handevaluator.h"
}

using namespace v8;

handeval_eq_class *holdemEval(Local<Array> cardlist, char *cards, char *hand);
handeval_eq_class *omahaEval(Local<Array> cardlist, char *cards, char *hand);

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
Local<Array> getCards(Local<Object> game,const char *field, Isolate *isolate) {
	return Local<Array>::Cast(game->Get(String::NewFromUtf8(isolate, field))->ToObject()->Get(String::NewFromUtf8(isolate, "cards")));
}
void RankHands(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    char cards[7];
    if (args.Length() < 2) {
        isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "wrong number of arguments")));
        return;
    }
    if (!args[0]->IsObject()) {
        isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "first argument must be a Game")));
        return;
    }
    if (!args[1]->IsArray()) {
        isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "second argument must be an array")));
        return;
    }
    Local<Object> root = Object::New(isolate);
    Local<Array> outputs = Array::New(isolate);
    root->Set(String::NewFromUtf8(isolate, "outputs"),outputs);

    Local<Object> game = args[0]->ToObject();
    Local<Array> flop = getCards(game, "flop", isolate);
    if (flop->Length() != 3) {
        isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "first argument must be a array of 3 Cards")));
        return;
    }
    cards[0] = cardToNumber(flop,0);
    cards[1] = cardToNumber(flop,1);
    cards[2] = cardToNumber(flop,2);
    cards[3] = cardToNumber(getCards(game, "turn", isolate),0);
    cards[4] = cardToNumber(getCards(game, "river", isolate),0);
    root->Set(String::NewFromUtf8(isolate, "input"), String::NewFromUtf8(isolate, hand_to_str(cards,5)));
    Local<Array> hands = Local<Array>::Cast(args[1]);
    for (unsigned int j=0; j<hands->Length(); j++) {
        Local<Value> item = hands->Get(j);
        handeval_eq_class *rank = 0;
        char handcards[4];
        int handsize = 0;
        if (!item->IsObject()) {
            isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "second argument must be an array of strings")));
            return;
        }
        Local<Object> hand = item->ToObject();
        Local<Array> cardlist = Local<Array>::Cast(hand->Get(String::NewFromUtf8(isolate, "hand"))); // array of Card objects
		
		if (cardlist->Length() == 2) {
			handsize = 2;
			rank = holdemEval(cardlist,cards,handcards);
		} else if (cardlist->Length() == 4) {
			handsize = 4;
			rank = omahaEval(cardlist,cards,handcards);
        } else {
            isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "a user can only have 2 or 4 cards")));
            return;
        }
        assert(rank);
        Local<Object> handOut = Object::New(isolate);

        handOut->Set(String::NewFromUtf8(isolate, "id"), Number::New(isolate, rank->id));
        handOut->Set(String::NewFromUtf8(isolate, "desc"), String::NewFromUtf8(isolate, rank->desc));
        handOut->Set(String::NewFromUtf8(isolate, "domination"), Number::New(isolate, rank->domination));
        handOut->Set(String::NewFromUtf8(isolate, "likelihood"), Number::New(isolate, rank->likelihood));
        handOut->Set(String::NewFromUtf8(isolate, "cards"), String::NewFromUtf8(isolate, rank->cards));
        handOut->Set(String::NewFromUtf8(isolate, "input"), String::NewFromUtf8(isolate, hand_to_str(handcards,handsize)));
        handOut->Set(String::NewFromUtf8(isolate, "seat"), hand->Get(String::NewFromUtf8(isolate, "seat")));
        outputs->Set(j,handOut);
    }
    args.GetReturnValue().Set(root);
}
handeval_eq_class *holdemEval(int a, int b, char *cards) {
	cards[5] = a;
	cards[6] = b;
	printf("ranking hand %s + %s\n",hand_to_str(cards,5),hand_to_str(cards+5,2));
	handeval_eq_class *rank = calculate_equivalence_class(cards);
	return rank;
}
handeval_eq_class *holdemEval(Local<Array> cardlist, char *cards,char *hand) {
	int a = cardToNumber(cardlist,0);
	int b = cardToNumber(cardlist,1);
	hand[0] = a;
	hand[1] = b;
	return holdemEval(a,b,cards);
}
handeval_eq_class *omahaEval(Local<Array> cardlist, char *cards,char *hand) {
	hand[0] = cardToNumber(cardlist,0);
	hand[1] = cardToNumber(cardlist,1);
	hand[2] = cardToNumber(cardlist,2);
	hand[3] = cardToNumber(cardlist,3);
	handeval_eq_class *best = holdemEval(hand[0],hand[1],cards);
	handeval_eq_class *test;

#define X(a,b) test = holdemEval(hand[a],hand[b],cards);\
	if (test->id < best->id) {\
		best = test;\
		puts("card " #a " and " #b " beat last one");\
	}
	X(0,2);
	X(0,3);
	X(1,2);
	X(1,3);
	X(2,3);
#undef X

	printf("%d %s vs %d %s\n",best->id,best->desc,test->id,test->desc);
	return best;
}
void InitDag(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    if (args.Length() != 1) {
        isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "wrong number of arguments")));
        return;
    }
    if (!args[0]->IsString()) {
        isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "first argument must be a path")));
        return;
    }
    String::Utf8Value project_root(args[0]->ToString());
    handeval_init(*project_root);
}
void init(Handle<Object> exports) {
    NODE_SET_METHOD(exports, "rankHands", RankHands);
    NODE_SET_METHOD(exports, "init", InitDag);
}

NODE_MODULE(dag,init)
