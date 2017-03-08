local hostname,port = ...

function onEvent(self, code, msg)
  print("event handler:"..code)
  handlers[code](self, msg)
end

local client1 = makeClient(hostname, port, onEvent)
print("client1:",client1)
client1:connect()
client1:sendHello()

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
handlers["srLoginReply"] = function (self, msg)
  if msg["login_status"] == "lrSuccess" then
    set_success(true);
  end
end

setTimeout(abort, 0, 5);
return true
