#include <stdint.h>
#include <lua.hpp>
#include <assert.h>
#include <iostream>

#include <event2/event.h>

#include "funcs.h"
#include "test-driver.h"

using namespace std;

static int client_connect(lua_State *L);
static int client_disconnect(lua_State *L);
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

static int delete_client(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  dump_stack(L, "finalizer");
  delete client;
  return 0;
}

static int client_login(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  assert(lua_isstring(L, 2));
  assert(lua_isstring(L, 3));
  client->login(lua_tostring(L, 2), lua_tostring(L, 3));
  return 0;
}

int makeClient(lua_State *L) {
  cout << __func__ << " top == " << lua_gettop(L) << "\n";
  assert(lua_isstring(L, 1));
  assert(lua_isnumber(L, 2));
  LuaTester *tester = static_cast<LuaTester*>(lua_touserdata(L, lua_upvalueindex(1)));

  string hostname = lua_tostring(L, 1);
  uint16_t port = lua_tointeger(L, 2);

  PokerClient *client = new PokerClient(tester, hostname, port);

  lua_createtable(L, 0, 0);
  int table = lua_gettop(L);
  printf("tbl %d\n", table);

  lua_createtable(L, 0, 0); // metatable

  luaL_Reg metatable[] = {
    { "__gc", delete_client },
    { NULL, NULL }
  };
  lua_pushlightuserdata(L, client);
  luaL_setfuncs(L, metatable, 1);

  lua_setmetatable(L, table);

  luaL_Reg funcs[] = {
    { "connect", client_connect },
    { "disconnect", client_disconnect },
    { "sendHello", client_sendHello },
    { "login", client_login },
    { NULL, NULL}
  };

  lua_pushlightuserdata(L, client);
  luaL_setfuncs(L, funcs, 1);
  
  cout << __func__ << " top == " << lua_gettop(L) << "\n";
  return 1;
}

int client_disconnect(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  client->disconnect();
  return 0;
}

int client_connect(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  lua_pushboolean(L, client->connect(gContext));
  return 1;
}

int client_sendHello(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  dump_stack(L, __func__);
  client->sendHello();
  return 0;
}

struct timer_state {
  lua_State *L;
  struct event *ev;
  int timerid;
};

static void handle_timeout(evutil_socket_t fd, short what, void *arg) {
  struct timer_state *ts = static_cast<struct timer_state*>(arg);
  //printf("DING from c++, %d, %d, %d\n", fd, what, timerid);
  lua_State *L = ts->L;
  lua_getfield(L, LUA_REGISTRYINDEX, "test-timers");
  lua_pushinteger(L, ts->timerid);
  lua_gettable(L, -2);

  int result = lua_pcall(L, 0, 0, 0);
  if (result != LUA_OK) {
    cout << "run error(" << result << "):" << lua_tostring(L, -1) << "\n";
    lua_remove(L, -1); // the error
  }
  lua_remove(L, -1); // test-timers tbl

  event_free(ts->ev);
  delete ts;
}

int set_success(lua_State *L) {
  LuaTester *t = static_cast<LuaTester*>(lua_touserdata(L, lua_upvalueindex(1)));
  t->set_success(lua_toboolean(L,1));
  return 0;
}

int setTimeout(lua_State *L) {
  struct event_base *base = static_cast<struct event_base*>(lua_touserdata(L, lua_upvalueindex(1)));
  int seconds = 0;
  if (lua_gettop(L) >= 3) seconds = lua_tointeger(L, 3);
  struct timeval delay = { seconds, lua_tointeger(L, 2) * 1000 };

  lua_getfield(L, LUA_REGISTRYINDEX, "test-timers");
  lua_getfield(L, -1, "counter");
  int counter = lua_tointeger(L, -1) + 1;
  lua_remove(L, -1);
  lua_pushinteger(L, counter);
  lua_setfield(L, -2, "counter");

  lua_pushinteger(L, counter);
  lua_pushvalue(L, 1);
  lua_settable(L, -3);

  struct timer_state *ts = new struct timer_state;
  ts->L = L;
  ts->timerid = counter;

  ts->ev = event_new(base, -1, EV_TIMEOUT, handle_timeout, ts);
  event_add(ts->ev, &delay);

  lua_pushinteger(L, counter);
  return 1;
}
