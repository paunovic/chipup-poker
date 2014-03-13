#include <node.h>
#include <v8.h>
#include <assert.h>


#include "poker_defs.h"
#include "enumdefs.h"

using namespace v8;

const int suits[] = { 0, 3, 2, 1 };

int cardToNumber(Local<Array> cards,int index) {
	int serverformat = cards->Get(index)->Int32Value();

	int value = serverformat / 4;
	int suit = serverformat % 4; // h s c d
	int out = suits[suit] * 13 + value;
	//printf("%d -> %d\n",serverformat,out);
	return out;
}
Local<Array> getCards(Local<Object> game,const char *field) {
	return Local<Array>::Cast(game->Get(String::NewSymbol(field))->ToObject()->Get(String::NewSymbol("cards")));
}
Handle<Value> rankHands(const Arguments &args) {
	HandleScope scope;
	int npockets = 2;
	int nboard = 5;
	int orderflag = 0;
	int err,i,card;
	StdDeck_CardMask pockets[ENUM_MAXPLAYERS];
	StdDeck_CardMask board;
	StdDeck_CardMask dead;
	enum_result_t result;
	enum_game_t game = game_omaha;

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

	enumResultClear(&result);
	StdDeck_CardMask_RESET(dead);
	StdDeck_CardMask_RESET(board);
	for (i=0; i<ENUM_MAXPLAYERS; i++)
		StdDeck_CardMask_RESET(pockets[i]);


	Local<Object> gameobj = args[0]->ToObject();
	Local<Array> flop = getCards(gameobj,"flop");
	if (flop->Length() != 3) {
		ThrowException(Exception::TypeError(String::New("first argument must be a array of 3 Cards")));
		return scope.Close(Undefined());
	}
	card = cardToNumber(flop,0); StdDeck_CardMask_SET(board,card); StdDeck_CardMask_SET(dead,card);
	card = cardToNumber(flop,1); StdDeck_CardMask_SET(board,card); StdDeck_CardMask_SET(dead,card);
	card = cardToNumber(flop,2); StdDeck_CardMask_SET(board,card); StdDeck_CardMask_SET(dead,card);
	card = cardToNumber(getCards(gameobj,"turn"),0); StdDeck_CardMask_SET(board,card); StdDeck_CardMask_SET(dead,card);
	card = cardToNumber(getCards(gameobj,"river"),0); StdDeck_CardMask_SET(board,card); StdDeck_CardMask_SET(dead,card);
	// 2h == 0
	// 3h == 1
	// Th == 8
	// Kh == 11
	// Ah == 12
	// 2d == 13
	// 2c == 26
	// 2s == 39
	// As == 51

	Local<Object> root = Object::New();

	Local<Array> hands = Local<Array>::Cast(args[1]);
	for (unsigned int j=0; j<hands->Length(); j++) {
		Local<Value> item = hands->Get(j);
		if (!item->IsObject()) {
			ThrowException(Exception::TypeError(String::New("second argument must be an array of strings")));
			return scope.Close(Undefined());
		}
		Local<Object> hand = item->ToObject();
		Local<Array> cardlist = Local<Array>::Cast(hand->Get(String::NewSymbol("hand"))); // array of Card objects
		
		card = cardToNumber(cardlist,0); StdDeck_CardMask_SET(pockets[j],card); StdDeck_CardMask_SET(dead,card);
		card = cardToNumber(cardlist,1); StdDeck_CardMask_SET(pockets[j],card); StdDeck_CardMask_SET(dead,card);
		card = cardToNumber(cardlist,2); StdDeck_CardMask_SET(pockets[j],card); StdDeck_CardMask_SET(dead,card);
		card = cardToNumber(cardlist,3); StdDeck_CardMask_SET(pockets[j],card); StdDeck_CardMask_SET(dead,card);
		npockets = j+1;
	}

	err = enumExhaustive(game, pockets, board, dead, npockets, nboard,orderflag, &result);
	if (err) {
		printf("err %d\n",err);
		return scope.Close(Undefined());
	} else {
		enumResultPrint(&result, pockets, board);
	}
	Local<Array> nwinhi = Array::New();
	int winners = 0;
	for (unsigned int j=0; j<hands->Length(); j++) {
		nwinhi->Set(j,Number::New(result.nwinhi[j]));
		winners += result.nwinhi[j];
		assert(!result.ntiehi[j]);
		assert(!result.nwinlo[j]);
	}
	assert(winners == 1);
	root->Set(String::NewSymbol("nwinhi"),nwinhi);
	return scope.Close(root);
}
void init(Handle<Object> exports) {
	exports->Set(String::NewSymbol("rankHands"),FunctionTemplate::New(rankHands)->GetFunction());
}
NODE_MODULE(omaha,init);
