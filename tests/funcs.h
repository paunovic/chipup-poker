#include <lua.hpp>

int makeClient(lua_State *L);
void dump_stack(lua_State *L, std::string context);
int setTimeout(lua_State *L);
int set_success(lua_State *L);
