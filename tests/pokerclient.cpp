#include <iostream>

#include <event2/bufferevent.h>
#include <event2/buffer.h>

#include "test-driver.h"
#include "message.pb.h"

using namespace std;
using namespace Poker;

void PokerClient::onRead(struct bufferevent *bev) {
  struct evbuffer *input = bufferevent_get_input(bev);
  char header_size[2];
  uint16_t real_header_size;

  if (evbuffer_get_length(input) < 2) return;
  ssize_t s = evbuffer_copyout(input, header_size, 2);
  assert(s == 2);
  real_header_size = header_size[0] | (header_size[1] << 8);

  if (evbuffer_get_length(input) < (2 + real_header_size)) return;

  char *raw = reinterpret_cast<char*>(evbuffer_pullup(input, 2 + real_header_size));
  assert(raw);
  string header_str(raw+2, real_header_size);
  RpcMessage header;
  header.ParseFromString(header_str);

  raw = reinterpret_cast<char*>(evbuffer_pullup(input, 2 + real_header_size + header.datasize()));
  assert(raw);

  string payload(raw + (2 + real_header_size), header.datasize());
  evbuffer_drain(input, 2 + real_header_size + header.datasize());
  handlePacket(header.methodid(), payload);
}
