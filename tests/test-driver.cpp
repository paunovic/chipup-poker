#include <stdint.h>
#include <string>
#include <openssl/ssl.h>
#include <stddef.h>
#include <iostream>
#include <unistd.h>

#include "message.pb.h"
#include "locking.h"

// https://wiki.openssl.org/index.php/SSL/TLS_Client

using namespace std;
using namespace Poker;

void *read_loop(void*data);
void hex_dump(string data) {
  for (int i=0; i < data.length(); i++) {
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
  Context() {
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

    result = SSL_CTX_load_verify_locations(ctx, "../qt-client/client/resources/DevServerCertificate.pem", NULL);
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

class Client {
public:
  Client(string hostname, uint16_t port) : hostname(hostname), port(port), state(Inactive) {
    socket = NULL;
    out = NULL;
    ssl = NULL;
  }
  ~Client() {
    if (out) BIO_free(out);
    if (socket) BIO_free_all(socket);
  }
  virtual void onConnect() = 0;
  bool connect(Context *context) __attribute__ ((warn_unused_result)) {
    int result;

    cout << "connecting\n";
    if (state != Inactive) return false;

    socket = BIO_new_ssl_connect(context->ctx);
    if (!socket) return false;

    char buffer[64];
    snprintf(buffer, 64, "%s:%d", hostname.c_str(), port);

    result = BIO_set_conn_hostname(socket, buffer);
    if (result != 1) return false;

    BIO_get_ssl(socket, &ssl);
    if (!ssl) return false;

    result = SSL_set_tlsext_host_name(ssl, hostname.c_str());
    if (result != 1) return false;

    out = BIO_new_fp(stdout, BIO_NOCLOSE);
    if (!out) return false;

    result = BIO_do_connect(socket);
    if (result != 1) return false;

    result = BIO_do_handshake(socket);
    if (result != 1) return false;

    {
      X509* cert = SSL_get_peer_certificate(ssl);

      X509_NAME* iname = X509_get_issuer_name(cert);
      print_cn_name("Issuer (cn)", iname);

      X509_NAME* sname = X509_get_subject_name(cert);
      print_cn_name("Subject (cn)", sname);

      if(cert) { X509_free(cert); } /* Free immediately */
      if (!cert) return false;
    }

    result = SSL_get_verify_result(ssl);
    if (result != X509_V_OK) {
      cout << "verify failed\n";
      return false;
    }

    state = Connected;
    onConnect();

    return true;
  }
  void disconnect() {
    SSL_shutdown(ssl);
  }
  bool write(const char *data, int len) {
    for (int i=0; i<len; i++) {
      //printf("%02x ", data[i]);
    }
    //printf("\n");
    BIO_write(socket, data, len);
    return true;
  };

  enum State {
    Inactive, Connecting, Connected, Disconnecting
  };
protected:
  BIO *socket;
private:
  string hostname;
  uint16_t port;
  State state;
  BIO *out;
  SSL* ssl;
};

class PokerClient : public Client {
public:
  PokerClient(string hostname, uint16_t port) : Client(hostname, port) {
  }
  ~PokerClient() {
    disconnect();
    keep_looping = false;
    void *retval;
    pthread_join(looper, &retval);
  }
  void sendHello() {
    HelloParams out;
    out.set_debug(false);
    out.set_appcode(HelloParams::acDelphiWindows);
    sendMessage(scHello, out);
  }
  void sendRegister(string username, string password, string email) {
    RegisterParams out;
    out.set_displayname(username);
    out.set_password(password);
    out.set_email(email);
    sendMessage(scRegister, out);
  }
  void login(string username, string password) {
    LoginParams out;
    out.set_username(username);
    out.set_password(password);
    sendMessage(scLogin, out);
  }
  virtual void onConnect() {
    pthread_attr_t attr;

    pthread_attr_init(&attr);
    pthread_create(&looper, &attr, &read_loop, this);
  }
  void *loop() {
    uint8_t header_size[2];
    uint16_t real_header_size;
    int r;
    string header_str, payload;

    keep_looping = true;
    while (keep_looping) {
      r = BIO_read(socket, header_size, 2);
      if (r != 2) break;
      real_header_size = header_size[0] | (header_size[1] << 8);

      header_str.resize(real_header_size);
      r = BIO_read(socket, &header_str[0], real_header_size);
      if (r != real_header_size) break;

      RpcMessage header;
      header.ParseFromString(header_str);

      int event_code = header.methodid();
      int payload_size = header.datasize();

      payload.resize(payload_size);
      r = BIO_read(socket, &payload[0], payload_size);
      if (r != payload_size) break;

      handlePacket(event_code, payload);
    }
    cout << "event loop quiting\n";
    return 0;
  }
  void handlePacket(int event_code, string payload_str) {
    printf("got event %d of size %lud\n", event_code, payload_str.size());
  }
  void sendMessage(Poker::ServerCodes code, const google::protobuf::Message &msg) {
    string payload;
    int i, n;
    string prefix;
    RpcMessage header;

    msg.SerializeToString(&payload);
    uint16_t payload_size = payload.length();
    cout << "payload size " << payload_size << "\n";
    cout << msg.DebugString() << "\n";

    header.set_methodid(code);
    header.set_datasize(payload_size);

    cout << header.DebugString() << "\n";

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
private:
    pthread_t looper;
    volatile bool keep_looping;
};

void *read_loop(void *data) {
  PokerClient *client = static_cast<PokerClient*>(data);
  return client->loop();
}

int main(int argc, char **argv) {
  thread_setup();
  SSL_library_init();
  Context context;
  string hostname = "dev-server.chipuppoker.com";
  uint16_t port  = 12346;
  int c;

  while ((c = getopt(argc, argv, "h:p:")) != -1) {
    switch (c) {
    case 'h':
      hostname = optarg;
      break;
    case 'p':
      port = strtol(optarg, 0, 10);
      break;
    }
  }

  PokerClient client(hostname, port);
  if (!client.connect(&context)) return -1;
  client.sendHello();
  sleep(10);
  cout << "done\n";
  thread_cleanup();
  return 0;
}
