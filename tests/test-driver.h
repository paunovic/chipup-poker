#include <openssl/ssl.h>
#include <string>
#include <lua.hpp>
#include <chrono>

#include <poker/message.pb.h>

class Context;
class LuaTester;

extern Context *gContext;

inline void set_context(Context *context) { gContext = context; }
inline const char *lua_pushstring(lua_State *L, const std::string str) {
  return lua_pushlstring(L, str.c_str(), str.length());
}

class Client {
public:
  Client(LuaTester *tester, std::string hostname, uint16_t port);
  virtual ~Client();
  virtual void onConnect() = 0;
  virtual void onRead(struct bufferevent *bev) = 0;
  bool connect(Context *context) __attribute__ ((warn_unused_result));
  void disconnect();
  bool write(const char *data, int len);

  LuaTester *tester;
private:
  std::string hostname;
  uint16_t port;
  SSL* ssl;
  struct bufferevent *bev;
};

class PokerClient : public Client {
public:
  PokerClient(LuaTester *tester, std::string hostname, uint16_t port);
  ~PokerClient();
  void sendHello();
  void sendRegister(std::string username, std::string password, std::string email);
  void login(std::string username, std::string password);
  virtual void onConnect();
  virtual void onRead(struct bufferevent *bev);
  void handlePacket(int event_code, std::string payload_str);
  void sendMessage(Poker::ServerCodes code, const google::protobuf::Message &msg);
  void sendMessage(lua_State *L, std::string code, int index);
  void sendMessage(lua_State *L, std::string code);
  void sendMessage(Poker::ServerCodes code);

private:
};

class LuaTester {
public:
  LuaTester(struct event_base *base);
  virtual ~LuaTester();
  void runTest(std::string path, std::string hostname, uint16_t port);
  void set_success(bool success);
  void event(std::string code, const google::protobuf::Message &msg, PokerClient *client);
  void event(std::string code, PokerClient *client);

  struct event_base *base;
  bool success;
  std::chrono::steady_clock::time_point start;
private:
  lua_State *L;
};
