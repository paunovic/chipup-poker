#include <node.h>
#include <v8.h>

#include "poker_defs.h"
#include "enumdefs.h"

using namespace v8;

Handle<Value> Method(const Arguments &args) {
	HandleScope scope;
	enum_sample_t enumType = ENUM_EXHAUSTIVE;
	int npockets = 2;
	int nboard = 5;
	int orderflag = 0;
	int err;
	StdDeck_CardMask pockets[ENUM_MAXPLAYERS];
	StdDeck_CardMask board;
	StdDeck_CardMask dead;
	enum_result_t result;
	enum_game_t game = game_omaha;

	enumResultClear(&result);

	int card;
	// 2h == 0
	// 3h == 1
	// Th == 8
	// Kh == 11
	// Ah == 12
	// 2d == 13
	// 2c == 26
	// 2s == 39
	// As == 51
	StdDeck_CardMask_SET(pockets[0],0);
	StdDeck_CardMask_SET(pockets[0],1);
	StdDeck_CardMask_SET(pockets[0],2);
	StdDeck_CardMask_SET(pockets[0],3);

	StdDeck_CardMask_SET(pockets[1],4);
	StdDeck_CardMask_SET(pockets[1],5);
	StdDeck_CardMask_SET(pockets[1],6);
	StdDeck_CardMask_SET(pockets[1],7);

	StdDeck_CardMask_SET(board,8);
	StdDeck_CardMask_SET(board,9);
	StdDeck_CardMask_SET(board,10);
	StdDeck_CardMask_SET(board,11);
	StdDeck_CardMask_SET(board,12);

	err = enumExhaustive(game, pockets, board, dead, npockets, nboard,orderflag, &result);
	if (err) printf("err %d\n",err);
	else {
		enumResultPrint(&result, pockets, board);
	}
	return scope.Close(String::New("world"));
}
void init(Handle<Object> exports) {
	exports->Set(String::NewSymbol("hello"),FunctionTemplate::New(Method)->GetFunction());
}
NODE_MODULE(omaha,init);
