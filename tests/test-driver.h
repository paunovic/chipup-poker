#include <openssl/ssl.h>
#include <string>

#include "message.pb.h"

class Context;

extern Context *gContext;

inline void set_context(Context *context) { gContext = context; }

class Client {
public:
  Client(std::string hostname, uint16_t port);
  ~Client();
  virtual void onConnect() = 0;
  bool connect(Context *context) __attribute__ ((warn_unused_result));
  void disconnect();
  bool write(const char *data, int len);

  enum State {
    Inactive, Connecting, Connected, Disconnecting
  };
protected:
  BIO *socket;
private:
  std::string hostname;
  uint16_t port;
  State state;
  BIO *out;
  SSL* ssl;
};

class PokerClient : public Client {
public:
  PokerClient(std::string hostname, uint16_t port);
  ~PokerClient();
  void sendHello();
  void sendRegister(std::string username, std::string password, std::string email);
  void login(std::string username, std::string password);
  virtual void onConnect();
  void *loop();
  void handlePacket(int event_code, std::string payload_str);
  void sendMessage(Poker::ServerCodes code, const google::protobuf::Message &msg);
private:
    pthread_t looper;
    volatile bool keep_looping;
};
