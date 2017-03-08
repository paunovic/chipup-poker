#include <stdint.h>
#include <lua.hpp>
#include <assert.h>
#include <iostream>

#include <event2/event.h>

#include "funcs.h"
#include "test-driver.h"
#include "message.pb.h"

using namespace std;
using namespace Poker;

static int client_connect(lua_State *L);
static int client_disconnect(lua_State *L);
static int client_sendHello(lua_State *L);

void pretty_print(lua_State *L, int i, string indent) {
  int initial = lua_gettop(L);
  int type = lua_type(L, i);
  cout << "(" << lua_typename(L, type) << ") ";
  switch (type) {
    case LUA_TSTRING:
    case LUA_TNUMBER:
      lua_pushvalue(L, i);
      cout << '"' << lua_tostring(L, -1) << '"';
      lua_remove(L, -1);
      break;
    case LUA_TTABLE:
      cout << "{\n";
      lua_pushnil(L);
      while (lua_next(L, i) != 0) {
        if (lua_type(L, -2) == LUA_TSTRING) {
          cout << indent << lua_tostring(L, -2) << " == ";
        } else if (lua_type(L, -2) == LUA_TNUMBER) {
          cout << indent << lua_tointeger(L, -2) << " == ";
        } else cout << indent << "other == ";
        pretty_print(L, lua_absindex(L, -1), indent + "  ");
        lua_pop(L, 1);
      }
      cout << indent << "}";
      break;
    default:
      cout << "other";
      break;
  }
  cout << "\n";
  assert(initial == lua_gettop(L));
}

void dump_stack(lua_State *L, string context) {
  cout << "dumping stack for: " << context << "\n";
  for (int i=1; i <= lua_gettop(L); i++) {
    cout << i << " ";
    pretty_print(L, i, "  ");
  }
  cout << "\n";
}

int dump_data(lua_State *L) {
  string context = luaL_checkstring(L, 1);
  dump_stack(L, context);
  return 0;
}

static int delete_client(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
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

static int client_register(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  string user = luaL_checkstring(L, 2);
  string pass = luaL_checkstring(L, 3);
  string email = luaL_checkstring(L, 4);
  client->sendRegister(user, pass, email);
  return 0;
}

static int client_scCreateClub(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  luaL_checktype(L, 2, LUA_TBOOLEAN);
  bool priv = lua_toboolean(L, 2);
  string name = luaL_checkstring(L, 3);
  string pass = luaL_checkstring(L, 4);
  int buyin_reset = luaL_checkint(L, 5);
  
  Club msg;
  msg.set_is_private(priv);
  msg.set_name(name);
  msg.set_password(pass);
  msg.set_rake(1);
  msg.set_buyin_reset(buyin_reset);
  client->sendMessage(scCreateClub, msg);
  return 0;
}

static int client_sendMessage(lua_State *L) {
  PokerClient *client = static_cast<PokerClient*>(lua_touserdata(L, lua_upvalueindex(1)));
  string code = luaL_checkstring(L, 2);
  int type = lua_type(L, 3);
  if (type == LUA_TTABLE) {
    luaL_checktype(L, 3, LUA_TTABLE);
    client->sendMessage(L, code, 3);
  } else {
    client->sendMessage(L, code);
  }
  return 0;
}

int makeClient(lua_State *L) {
  cout << __func__ << " top == " << lua_gettop(L) << "\n";
  luaL_checkstring(L, 1);
  luaL_checkint(L, 2);
  luaL_checktype(L, 3, LUA_TFUNCTION);
  LuaTester *tester = static_cast<LuaTester*>(lua_touserdata(L, lua_upvalueindex(1)));

  string hostname = lua_tostring(L, 1);
  uint16_t port = lua_tointeger(L, 2);

  PokerClient *client = new PokerClient(tester, hostname, port);

  lua_createtable(L, 0, 0); // 4
  int table = lua_gettop(L);
  printf("tbl %d\n", table);

  lua_createtable(L, 0, 0); // 5 metatable

  luaL_Reg metatable[] = {
    { "__gc", delete_client },
    { NULL, NULL }
  };
  lua_pushlightuserdata(L, client); // 6
  luaL_setfuncs(L, metatable, 1); // -1

  lua_setmetatable(L, table); // -1

  luaL_Reg funcs[] = {
    { "connect", client_connect },
    { "disconnect", client_disconnect },
    { "sendHello", client_sendHello },
    { "login", client_login },
    { "register", client_register },
    { "scCreateClub", client_scCreateClub },
    { "sendMessage", client_sendMessage },
    { NULL, NULL}
  };

  lua_pushlightuserdata(L, client); // 5
  luaL_setfuncs(L, funcs, 1); // -1

  lua_pushvalue(L, 3);
  lua_setfield(L, -2, "onEvent");

  luaL_newmetatable(L, "testdriver.connections"); // 5
  lua_pushlightuserdata(L, client); // 6
  lua_pushvalue(L, -3); // 7
  lua_settable(L, -3); // -2
  lua_pop(L, 1); // -1
  
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
