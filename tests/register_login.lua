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
handlers["srLoginReply"] = function (msg)
  if msg["login_status"] == "lrSuccess" then
    set_success(true);
  end
end
function onEvent(code, msg)
  print("event handler:"..code)
  handlers[code](msg)
end

setTimeout(ding, 0, 1);
setTimeout(abort, 0, 5);
return true
