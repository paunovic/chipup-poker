#include <stdint.h>
#include <stddef.h>
#include <iostream>
#include <unistd.h>
#include <lua.hpp>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <event2/thread.h>
#include <event2/event.h>
#include <event2/bufferevent_ssl.h>

#include "locking.h"
#include "funcs.h"
#include "test-driver.h"

// https://wiki.openssl.org/index.php/SSL/TLS_Client

using namespace std;
using namespace Poker;

void *read_loop(void*data);

Context *gContext = NULL;

void hex_dump(string data) {
  for (unsigned int i=0; i < data.length(); i++) {
    uint8_t c = data[i];
    printf("%02x ", c);
  }
  printf("\n");
}

void print_cn_name(const char* label, X509_NAME* const name) {
  int idx = -1, success = 0;
  unsigned char *utf8 = NULL;

  do {
    if(!name) break; /* failed */

    idx = X509_NAME_get_index_by_NID(name, NID_commonName, -1);
    if(!(idx > -1))  break; /* failed */

    X509_NAME_ENTRY* entry = X509_NAME_get_entry(name, idx);
    if(!entry) break; /* failed */

    ASN1_STRING* data = X509_NAME_ENTRY_get_data(entry);
    if(!data) break; /* failed */

    int length = ASN1_STRING_to_UTF8(&utf8, data);
    if(!utf8 || !(length > 0))  break; /* failed */

    fprintf(stdout, "  %s: %s\n", label, utf8);
    success = 1;
  } while(0);

  if(utf8) OPENSSL_free(utf8);

  if(!success) fprintf(stdout, "  %s: <not available>\n", label);
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
    if (result != 1) abort();
    
    const char* const PREFERRED_CIPHERS = "HIGH:!aNULL:!kRSA:!PSK:!SRP:!MD5:!RC4";
    result = SSL_CTX_set_cipher_list(ctx, PREFERRED_CIPHERS);
    if (result != 1) abort();

  }
  ~Context() {
    if (ctx) SSL_CTX_free(ctx);
  }

  SSL_CTX *ctx;
};

Client::Client(LuaTester *tester, string hostname, uint16_t port) : tester(tester), hostname(hostname), port(port), state(Inactive) {
  ssl = NULL;
}

Client::~Client() {
  if (bev) bufferevent_free(bev);
  if (ssl) SSL_free(ssl);
}

void client_readcb(struct bufferevent *bev, void *ctx) {
  cout << __func__ << "\n";
  Client *client = static_cast<Client*>(ctx);
  client->onRead(bev);;
}

void client_eventcb(struct bufferevent *bev, short events, void *ctx) {
  cout << __func__ << "\n";
}

void Client::disconnect() {
  SSL_shutdown(ssl);
}

bool Client::write(const char *data, int len) {
  for (int i=0; i<len; i++) {
    //printf("%02x ", data[i]);
  }
  //printf("\n");
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

void PokerClient::handlePacket(int event_code, string payload) {
  printf("got event %d of size %lud\n", event_code, payload.size());
  switch (event_code) {
  case srHello: // 1
  {
    HelloReply msg;
    msg.ParseFromString(payload);
    tester->event("srHello");
    break;
  }
  case srLoginReply: // 2
  {
    LoginReply msg;
    msg.ParseFromString(payload);
    //cout << msg.DebugString() << "\n";
    if (msg.login_status() == LoginReply::lrSuccess) {
      tester->event("srLoginReply");
    } else {
      tester->event("srLoginReply-"); // TODO improve the ability set attributes
    }
    break;
  }
  case srRegisterReply: // 3
  {
    RegisterReply msg;
    msg.ParseFromString(payload);
    cout << msg.DebugString() << "\n";
    if (msg.status() == RegisterReply::regSuccess) {
      tester->event("srRegisterReply");
    } else {
      tester->event("srRegisterReply-");
    }
    break;
  }
  case srCreateClubReply: // 4
  {
    ClubCommandReply msg;
    msg.ParseFromString(payload);
    cout << msg.DebugString() << "\n";
    if (msg.status() == ClubCommandReply::csSuccess) {
      tester->event("srCreateClubReply");
    } else {
      tester->event("srCreateClubReply-");
    }
    break;
  }
  }
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
    printf("sent event %d of size %ud\n", code, packet_size);
  }

LuaTester::LuaTester(struct event_base *base) : base(base) {
  L = luaL_newstate();
  success = false;
  luaL_openlibs(L);

  cout << "top == " << lua_gettop(L) << "\n";
  lua_pushlightuserdata(L, this);
  lua_pushcclosure(L, makeClient, 1);
  lua_setglobal(L, "makeClient");

  lua_pushlightuserdata(L, this);
  lua_pushcclosure(L, ::set_success, 1);
  lua_setglobal(L, "set_success");
  
  lua_createtable(L, 0, 0);
  lua_pushinteger(L, 0);
  lua_setfield(L, -2, "counter");
  lua_setfield(L, LUA_REGISTRYINDEX, "test-timers");
  
  lua_pushlightuserdata(L, base);
  lua_pushcclosure(L, setTimeout, 1);
  lua_setglobal(L, "setTimeout");
  
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
    abort();
  }
  lua_pushstring(L, hostname.c_str());
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

void LuaTester::event(string code) {
  lua_getglobal(L, "onEvent");
  if (lua_type(L, -1) == LUA_TNIL) {
    lua_remove(L, -1);
    return;
  }
  lua_pushstring(L, code.c_str());
  int result = lua_pcall(L, 1, 0, 0);
  if (result != LUA_OK) {
    cout << "run error(" << result << "):" << lua_tostring(L, -1) << "\n";
    lua_remove(L, -1);
  }
}

bool Client::connect(Context *context) {
  struct addrinfo *out;
  int res;
  res = getaddrinfo(hostname.c_str(), NULL, NULL, &out);
  assert(res == 0);
  int fd = ::socket(AF_INET, SOCK_STREAM, 0);
  assert(fd != -1);
  struct sockaddr_in *addr = reinterpret_cast<struct sockaddr_in*>(out->ai_addr);
  addr->sin_port = htons(port);
  res = ::connect(fd, out->ai_addr, out->ai_addrlen);
  assert(res == 0);
  
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
    return -1;
  }
  return 0;
}
