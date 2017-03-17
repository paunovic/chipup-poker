#include <stdint.h>
#include <stddef.h>
#include <iostream>
#include <unistd.h>
#include <lua.hpp>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <iomanip>

#include <event2/thread.h>
#include <event2/event.h>
#include <event2/bufferevent_ssl.h>

#include "locking.h"
#include "funcs.h"
#include "test-driver.h"

// https://wiki.openssl.org/index.php/SSL/TLS_Client

using namespace std;
using namespace Poker;
using namespace std::chrono;

void *read_loop(void*data);

Context *gContext = NULL;

void hex_dump(string data) {
  for (unsigned int i=0; i < data.length(); i++) {
    uint8_t c = data[i];
    printf("%02x ", c);
  }
  printf("\n");
}

class Context {
public:
  Context(string certpath) {
    int result;
    const SSL_METHOD* method = SSLv23_method();
    if (!method) abort();
    
    ctx = SSL_CTX_new(method);
    if (!ctx) abort();

    //SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, verify_callback);
    SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL);
    SSL_CTX_set_verify_depth(ctx, 4);

    const long flags = SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3 | SSL_OP_NO_COMPRESSION;
    SSL_CTX_set_options(ctx, flags);

    result = SSL_CTX_load_verify_locations(ctx, certpath.c_str(), NULL);
    assert(result == 1);
    
    const char* const PREFERRED_CIPHERS = "HIGH:!aNULL:!kRSA:!PSK:!SRP:!MD5:!RC4";
    result = SSL_CTX_set_cipher_list(ctx, PREFERRED_CIPHERS);
    assert(result == 1);
  }
  ~Context() {
    if (ctx) SSL_CTX_free(ctx);
  }

  SSL_CTX *ctx;
};

Client::Client(LuaTester *tester, string hostname, uint16_t port) : tester(tester), hostname(hostname), port(port) {
  ssl = NULL;
  bev = NULL;
}

Client::~Client() {
  if (bev) bufferevent_free(bev);
  if (ssl) SSL_free(ssl);
}

void client_readcb(struct bufferevent *bev, void *ctx) {
  Client *client = static_cast<Client*>(ctx);
  client->onRead(bev);;
}

void client_eventcb(struct bufferevent *bev, short events, void *ctx) {
  cout << __func__ << "\n";
}

void Client::disconnect() {
  if (ssl) SSL_shutdown(ssl);
}

bool Client::write(const char *data, int len) {
  int result = bufferevent_write(bev, data, len);
  assert(result == 0);
  return true;
}

PokerClient::PokerClient(LuaTester *tester, string hostname, uint16_t port) : Client(tester, hostname, port) {
}

PokerClient::~PokerClient() {
  disconnect();
}

void PokerClient::sendHello() {
  HelloParams out;
  out.set_debug(false);
  out.set_appcode(HelloParams::acDelphiWindows);
  sendMessage(scHello, out);
}

void PokerClient::sendRegister(string username, string password, string email) {
  RegisterParams out;
  out.set_displayname(username);
  out.set_password(password);
  out.set_email(email);
  sendMessage(scRegister, out);
}

void PokerClient::login(string username, string password) {
  LoginParams out;
  out.set_username(username);
  out.set_password(password);
  sendMessage(scLogin, out);
}

void PokerClient::onConnect() {
}

struct EventInfo {
  google::protobuf::Message *m;
  string name;
  const ::google::protobuf::Descriptor *descriptor;
};

static void debug_print_ts(LuaTester *tester) {
  steady_clock::time_point now = steady_clock::now();
  duration<double> time_span = duration_cast<duration<double>>(now - tester->start);
  double time = time_span.count();
  cout << "<" << setw(9) << time << "> ";
}

struct EventInfo events[200];

void init_events() {
  for (int i=0; i<200; i++) events[i].m = NULL;

#define x(CODE, CLASS) events[CODE] = { new CLASS(), #CODE, CLASS::descriptor() }

  x(srHello, HelloReply);
  x(srLoginReply, LoginReply);
  x(srRegisterReply, RegisterReply);
  x(srCreateClubReply, ClubCommandReply); // 4
  x(srJoinClubReply, ClubCommandReply); // 5

  x(srChangeClubDetailsReply, ClubCommandReply); // 7

  x(srCreateGameOk, Game); // 24

  x(srTableSitOk, TableStatus); // 27

  x(srTableStandUpOk, TableStatus); // 29

  x(srTableStatsReply, TableStatsReplies); // 35

  x(srPlayerLimitOk, PlayerLimitParams); // 39

  x(srHandHistoryMsg, HandHistoryReply); // 42

  x(seClubChange, Club); // 53

  x(seGameChange, Game); // 55
  x(seGameCreate, Game); // 56
  x(seGameDelete, Game); // 57
  x(seTableStatus, TableStatus); // 58

  x(sePlayerClubStatus, PlayerClubStatus); // 63

  x(scHello, HelloParams);
  x(scLogin, LoginParams);
  x(scRegister, RegisterParams); // 73

  x(scCreateClub, Club); // 76
  x(scJoinClub, Club); // 77

  x(scChangeClubDetails, Club); // 81

  x(scCreateGame, Game); // 87
  x(scCloseGame, CloseGameData); // 88
  x(scTableJoin, Game); // 89
  x(scTableLeave, Game); // 90
  x(scTableSit, TableSit); // 91
  x(scTableStandUp, Game); // 92

  x(scPutChips, PutChips); // 97

  x(scTablePlayNow, Game); // 99
  x(scTableSitOutNextHand, TableBoolFlag); // 100

  x(scSetPlayerLimit, PlayerLimitParams); // 106

  x(scApproveClubMember, ChangeClubPlayerFlag); // 121
#undef x
}

void PokerClient::handlePacket(int event_code, string payload) {
  //printf("got event %d of size %lud\n", event_code, payload.size());
  google::protobuf::Message *m = NULL;
  switch (event_code) {
  case 0:
    cout << "code 0 " << payload << "\n";
    break;
  case ServerCodes::srLogout:
    tester->event("srLogout", this);
    return;
  }
  if (events[event_code].m) {
    m = events[event_code].m->New();
    m->ParseFromString(payload);
    tester->event(events[event_code].name, *m, this);
    delete m;
  } else {
    cout << "unhandled event code " << event_code << "\n";
  }
}

void PokerClient::sendMessage(lua_State *L, string code_str, int index) {
  using namespace google::protobuf;
  const ::google::protobuf::EnumDescriptor* ed = ServerCodes_descriptor();
  Poker::ServerCodes code;
  auto evd = ed->FindValueByName(code_str);
  if (!evd) {
    luaL_error(L, "invalid server code");
    return;
  }
  code = (Poker::ServerCodes) evd->number();

  auto eventInfo = events[code];
  if (!eventInfo.m) {
    luaL_error(L, "class for code %s not configured", code_str.c_str());
    return;
  }
  debug_print_ts(tester);
  cout << "OUT " << code_str << "\n";

  google::protobuf::Message *out = eventInfo.m->New();;
  auto descriptor = eventInfo.descriptor;
  auto r = out->GetReflection();
  evd = NULL;
  lua_pushnil(L);
  while (lua_next(L, index) != 0) {
    luaL_checkstring(L, -2);
    string field_name = lua_tostring(L, -2);
    auto f = descriptor->FindFieldByName(field_name);
    if (!f) {
      delete out;
      luaL_error(L, "field %s not in protobuf", field_name.c_str());
      return;
    }
    switch (f->type()) {
    case FieldDescriptor::TYPE_INT32: // 5
      luaL_checkint(L, -1);
      r->SetInt32(out, f, lua_tointeger(L, -1));
      break;
    case FieldDescriptor::TYPE_BOOL: // 8
      luaL_checktype(L, -1, LUA_TBOOLEAN);
      r->SetBool(out, f, lua_toboolean(L, -1));
      break;
    case FieldDescriptor::TYPE_STRING: // 9
      luaL_checkstring(L, -1);
      r->SetString(out, f, lua_tostring(L, -1));
      break;
    case FieldDescriptor::TYPE_BYTES: // 12
      luaL_checkstring(L, -1);
      r->SetString(out, f, lua_tostring(L, -1));
      break;
    case FieldDescriptor::TYPE_UINT32: // 13
      luaL_checkint(L, -1);
      r->SetUInt32(out, f, lua_tointeger(L, -1));
      break;
    case FieldDescriptor::TYPE_ENUM: // 14
      evd = f->enum_type()->FindValueByName(lua_tostring(L, -1));
      if (!evd) {
        luaL_error(L, "invalid enum value %s", lua_tostring(L, -1));
        return;
      }
      r->SetEnum(out, f, evd);
      break;
    default:
      delete out;
      luaL_error(L, "type %d not supported on field %s", f->type(), field_name.c_str());
      return;
    }

    lua_pop(L, 1);
  }
  if (!out->IsInitialized()) {
    string errmsg = out->InitializationErrorString();
    delete out;
    luaL_error(L, "required fields not set: %s", errmsg.c_str());
    return;
  }
  sendMessage(code, *out);
  delete out;
}

void PokerClient::sendMessage(lua_State *L, string code_str) {
  using namespace google::protobuf;
  const ::google::protobuf::EnumDescriptor* ed = ServerCodes_descriptor();
  Poker::ServerCodes code;
  auto evd = ed->FindValueByName(code_str);

  debug_print_ts(tester);
  cout << "OUT " << code_str << "\n";

  if (!evd) {
    luaL_error(L, "invalid server code");
    return;
  }
  code = (Poker::ServerCodes) evd->number();
  sendMessage(code);
}

void PokerClient::sendMessage(Poker::ServerCodes code, const google::protobuf::Message &msg) {
  string payload, prefix;
  unsigned int i, n;
  RpcMessage header;

  msg.SerializeToString(&payload);
  uint16_t payload_size = payload.length();

  header.set_methodid(code);
  header.set_datasize(payload_size);

  header.SerializeToString(&prefix);

  int packet_size = 2 + prefix.length() + payload_size;
  char buffer[packet_size];
  n=0;
  buffer[n++] = prefix.length() & 0xff;
  buffer[n++] = prefix.length() >> 8;

  const char *prefix_raw = prefix.data();
  for (i=0; i<prefix.length(); i++) {
    buffer[n++] = prefix_raw[i];
  }
  const char *payload_raw = payload.data();
  for (i=0; i<payload_size; i++) {
    buffer[n++] = payload_raw[i];
  }
  write(buffer, packet_size);
  //printf("sent event %d of size %ud\n", code, packet_size);
}

void PokerClient::sendMessage(Poker::ServerCodes code) {
  int n, i;
  string prefix;
  RpcMessage header;
  header.set_methodid(code);
  header.set_datasize(0);
  header.SerializeToString(&prefix);

  int packet_size = 2 + prefix.length();
  char buffer[packet_size];
  n=0;
  buffer[n++] = prefix.length() & 0xff;
  buffer[n++] = prefix.length() >> 8;
  const char *prefix_raw = prefix.data();
  for (i=0; i<prefix.length(); i++) {
    buffer[n++] = prefix_raw[i];
  }
  write(buffer, packet_size);
}

static int debug_print(lua_State *L) {
  LuaTester *tester = static_cast<LuaTester*>(lua_touserdata(L, lua_upvalueindex(1)));
  debug_print_ts(tester);

  for (int i=1; i <= lua_gettop(L); i++) {
    lua_pushvalue(L, i);
    if (lua_type(L, -1) == LUA_TSTRING) {
      cout << lua_tostring(L, -1);
    } else {
      cout << "other";
    }
    lua_pop(L, 1);
  }
  cout << "\n";
  return 0;
}

LuaTester::LuaTester(struct event_base *base) : base(base) {
  L = luaL_newstate();
  success = false;
  luaL_openlibs(L);

  cout << "top == " << lua_gettop(L) << "\n";

  lua_createtable(L, 0, 0);
  lua_pushinteger(L, 0);
  lua_setfield(L, -2, "counter");
  lua_setfield(L, LUA_REGISTRYINDEX, "test-timers");
  
  lua_pushlightuserdata(L, base);
  lua_pushcclosure(L, setTimeout, 1);
  lua_setglobal(L, "setTimeout");
  
  
  luaL_Reg funcs[] = {
    { "dump", dump_data },
    { "dbg", debug_print },
    { "makeClient", makeClient },
    { "set_success", ::set_success },
    { "assert_eq", my_assert_eq },
    { NULL, NULL }
  };
  
  lua_pushglobaltable(L);
  lua_pushlightuserdata(L, this);
  luaL_setfuncs(L, funcs, 1);
  lua_pop(L, 1);

  start = steady_clock::now();

  cout << "top == " << lua_gettop(L) << "\n";
}

LuaTester::~LuaTester() {
  lua_close(L);
}

void LuaTester::set_success(bool success) {
  this->success = success;
}

void LuaTester::runTest(string path, string hostname, uint16_t port) {
  int result;

  cout << "top == " << lua_gettop(L) << "\n";

  result = luaL_loadfilex(L, path.c_str(), NULL);
  if (result != LUA_OK) {
    cout << "load error:" << lua_tostring(L, -1) << "\n";
  }
  assert(result == LUA_OK);
  lua_pushstring(L, hostname);
  lua_pushinteger(L, port);

  result = lua_pcall(L, 2, 1, 0);
  if (result != LUA_OK) {
    cout << "run error(" << result << "):" << lua_tostring(L, -1) << "\n";
    abort();
  }
  bool retval = lua_toboolean(L, -1);
  lua_remove(L, -1);
  cout << "retval:" << retval << "\n";

  if (!retval) {
    cerr << "test init failed\n";
    abort();
  }

  result = event_base_loop(base, 0);
  cout << "ev result:" << result << "\n";
    
  cout << "top == " << lua_gettop(L) << "\n";
}

void message_to_table(lua_State *L, const google::protobuf::Message &msg);

void field_to_lua(lua_State *L, const google::protobuf::Reflection *r, const google::protobuf::Message &msg, const google::protobuf::FieldDescriptor *f) {
  using namespace google::protobuf;
  string scratch;
  switch (f->cpp_type()) {
  case FieldDescriptor::CPPTYPE_INT32: // 1
    lua_pushinteger(L, r->GetInt32(msg, f));
    break;
  case FieldDescriptor::CPPTYPE_UINT32:
    lua_pushinteger(L, r->GetUInt32(msg, f));
    break;
  case FieldDescriptor::CPPTYPE_BOOL: // 7
    lua_pushboolean(L, r->GetBool(msg, f));
    break;
  case FieldDescriptor::CPPTYPE_ENUM: // 8
    lua_pushstring(L, r->GetEnum(msg, f)->name());
    break;
  case FieldDescriptor::CPPTYPE_STRING:
    lua_pushstring(L, r->GetStringReference(msg, f, &scratch));
    break;
  case FieldDescriptor::CPPTYPE_MESSAGE:
    message_to_table(L, r->GetMessage(msg, f));
    break;
  default:
    lua_pushstring(L, (string("other") + to_string(f->cpp_type())));
  }
}

void field_to_lua(lua_State *L, const google::protobuf::Reflection *r, const google::protobuf::Message &msg, const google::protobuf::FieldDescriptor *f, int index) {
  using namespace google::protobuf;
  string scratch;
  switch (f->cpp_type()) {
  case FieldDescriptor::CPPTYPE_INT32:
    lua_pushinteger(L, r->GetRepeatedInt32(msg, f, index));
    break;
  case FieldDescriptor::CPPTYPE_UINT32:
    lua_pushinteger(L, r->GetRepeatedUInt32(msg, f, index));
    break;
  case FieldDescriptor::CPPTYPE_ENUM:
    lua_pushstring(L, r->GetRepeatedEnum(msg, f, index)->name());
    break;
  case FieldDescriptor::CPPTYPE_STRING:
    lua_pushstring(L, r->GetRepeatedStringReference(msg, f, index, &scratch));
    break;
  case FieldDescriptor::CPPTYPE_MESSAGE:
    message_to_table(L, r->GetRepeatedMessage(msg, f, index));
    break;
  default:
    lua_pushstring(L, (string("other") + to_string(f->cpp_type())));
  }
}

void message_to_table(lua_State *L, const google::protobuf::Message &msg) {
  using namespace google::protobuf;
  const Reflection *r = msg.GetReflection();
  vector<const FieldDescriptor*> fields;
  r->ListFields(msg, &fields);

  lua_createtable(L, 0, 0);

  for (vector<const FieldDescriptor*>::iterator it = fields.begin(); it != fields.end(); ++it) {
    const FieldDescriptor *f = *it;
    if (f->is_repeated()) {
      int count = r->FieldSize(msg, f);
      lua_createtable(L, count, 0);
      for (int i=0; i<count; i++) {
        lua_pushinteger(L, i + 1);
        field_to_lua(L, r, msg, f, i);
        lua_settable(L, -3);
      }
    } else {
      field_to_lua(L, r, msg, f);
    }
    lua_setfield(L, -2, f->name().c_str());
  }

  //dump_stack(L, "made table");
}

void LuaTester::event(string code, PokerClient *client) {
  luaL_getmetatable(L, "testdriver.connections"); // 1
  lua_pushlightuserdata(L, client); // 2
  lua_gettable(L, -2); // 2
  lua_remove(L, -2); // -1
  lua_getfield(L, -1, "onEvent");
  if (lua_type(L, -1) != LUA_TFUNCTION) {
    lua_pop(L, 2);
    return;
  }

  lua_pushvalue(L, -2);
  lua_remove(L, -3);
  lua_pushstring(L, code);

  int result = lua_pcall(L, 2, 0, 0);
  if (result != LUA_OK) {
    cout << "run error(" << result << "):" << lua_tostring(L, -1) << "\n";
    lua_remove(L, -1);
  }
  assert(lua_gettop(L) == 0);
}

void LuaTester::event(string code, const google::protobuf::Message &msg, PokerClient *client) {
  luaL_getmetatable(L, "testdriver.connections"); // 1
  lua_pushlightuserdata(L, client); // 2
  lua_gettable(L, -2); // 2
  lua_remove(L, -2); // -1
  lua_getfield(L, -1, "onEvent");
  if (lua_type(L, -1) != LUA_TFUNCTION) {
    lua_pop(L, 2);
    return;
  }

  lua_pushvalue(L, -2);
  lua_remove(L, -3);
  lua_pushstring(L, code);
  message_to_table(L, msg);

  int result = lua_pcall(L, 3, 0, 0);
  if (result != LUA_OK) {
    cout << "run error(" << result << "):" << lua_tostring(L, -1) << "\n";
    lua_remove(L, -1);
    abort();
  }
  assert(lua_gettop(L) == 0);
}

bool Client::connect(Context *context) {
  struct addrinfo *out;
  int res;
  res = getaddrinfo(hostname.c_str(), NULL, NULL, &out);
  assert(res == 0);

  if (out->ai_addr->sa_family == AF_INET) {
    struct sockaddr_in *addr = reinterpret_cast<struct sockaddr_in*>(out->ai_addr);
    addr->sin_port = htons(port);
  } else if (out->ai_addr->sa_family == AF_INET6) {
    struct sockaddr_in6 *addr = reinterpret_cast<struct sockaddr_in6*>(out->ai_addr);
    addr->sin6_port = htons(port);
  } else {
    cout << "unsupported address family\n";
    abort();
  }

  int fd = ::socket(out->ai_addr->sa_family, SOCK_STREAM, 0);
  if (fd == -1) {
    int saved = errno;
    cout << strerror(saved) << " while trying to create socket\n";
    abort();
  }
  res = ::connect(fd, out->ai_addr, out->ai_addrlen);
  if (res == -1) {
    int saved = errno;
    cout << strerror(saved) << " while trying to connect to server\n";
    abort();
  }
  
  freeaddrinfo(out);
  out = NULL;

  ssl = SSL_new(context->ctx);

  bev = bufferevent_openssl_socket_new(tester->base, fd, ssl, BUFFEREVENT_SSL_CONNECTING, 0);
  bufferevent_enable(bev, EV_READ);
  bufferevent_setcb(bev, client_readcb, NULL, client_eventcb, this);
  return true;
}

int main(int argc, char **argv) {
  thread_setup();
  evthread_use_pthreads();
  SSL_library_init();
  init_events();
  string hostname = "dev-server.chipuppoker.com";
  string certpath = "../qt-client/client/resources/DevServerCertificate.pem";
  uint16_t port  = 12346;
  int c;
  string codepath;
  struct event_base *base = event_base_new();
  assert(base);
  printf("Using Libevent with backend method %s.\n", event_base_get_method(base));

  while ((c = getopt(argc, argv, "h:p:c:e:")) != -1) {
    switch (c) {
    case 'h':
      hostname = optarg;
      break;
    case 'p':
      port = strtol(optarg, 0, 10);
      break;
    case 'c':
      codepath = optarg;
      break;
    case 'e':
      certpath = optarg;
      break;
    }
  }
  
  Context context(certpath);
  set_context(&context);

  bool success;
  {
    LuaTester t(base);
    t.runTest(codepath, hostname, port);
    success = t.success;
  }

  set_context(NULL);
  cout << "done\n";
  thread_cleanup();
  event_base_free(base);
  // needs 2.1 libevent_global_shutdown();
  if (!success) {
    cout << "test failed\n";
    cout.flush();
    return -2;
  }
  return 0;
}
