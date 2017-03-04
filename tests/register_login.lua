local hostname,port = ...

print("need to connect to "..hostname..":"..port)

local client1 = makeClient(hostname, port)
print("client1:",client1)
client1:connect()
client1:sendHello()

function ding()
  print("ding from lua");
end
function abort()
  print("timeout, failing")
  client1:disconnect()
end
handlers = {}
handlers["srHello"] = function ()
  print("got hello reply")
  client1:register("username", "password", "email@example.com")
end
handlers["srRegisterReply"] = function ()
  client1:login("username","password")
end
handlers["srLoginReply"] = function ()
  set_success(true);
end
function onEvent(code)
  print("event handler:"..code)
  handlers[code]()
end

setTimeout(ding, 0, 1);
setTimeout(abort, 0, 5);
return true
