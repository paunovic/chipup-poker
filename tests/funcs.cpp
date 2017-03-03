#include <stdint.h>
#include <lua.hpp>
#include <assert.h>
#include <iostream>

#include "funcs.h"
#include "test-driver.h"

using namespace std;

static int client_connect(lua_State *L);
static int client_sendHello(lua_State *L);

void dump_stack(lua_State *L, string context) {
  cout << "dumping stack for: " << context << "\n";
  for (int i=1; i <= lua_gettop(L); i++) {
    int type = lua_type(L, i);
    cout << i << " " << lua_typename(L, type) << " == ";
    switch (type) {
    case LUA_TSTRING:
    case LUA_TNUMBER:
      lua_pushvalue(L, i);
      cout << lua_tostring(L, -1);
      lua_remove(L, -1);
      break;
    default:
      cout << "other";
      break;
    }
    cout << "\n";
  }
  cout << "\n";
}

int makeClient(lua_State *L) {
  cout << __func__ << " top == " << lua_gettop(L) << "\n";
  assert(lua_isstring(L, 1));
  assert(lua_isnumber(L, 2));

  string hostname = lua_tostring(L, 1);
  uint16_t port = lua_tointeger(L, 2);

  PokerClient *client = new PokerClient(hostname, port);

  lua_createtable(L, 0, 0);
  int table = lua_gettop(L);
  printf("tbl %d\n", table);

  lua_pushlightuserdata(L, client);
  lua_pushcclosure(L, client_connect, 1);
  lua_setfield(L, table, "connect");
  
  lua_pushlightuserdata(L, client);
  lua_pushcclosure(L, client_sendHello, 1);
  lua_setfield(L, table, "sendHello");

  cout << __func__ << " top == " << lua_gettop(L) << "\n";
  dump_stack(L, "reting");
  return 1;
}

int client_connect(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  dump_stack(L, "in connect");
  lua_pushboolean(L, client->connect(gContext));
  return 1;
}

int client_sendHello(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  dump_stack(L, __func__);
  client->sendHello();
  return 0;
}
