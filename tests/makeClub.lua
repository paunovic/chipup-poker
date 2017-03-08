local hostname,port = ...
handlers = {}

function onEvent(self, code, obj)
  dbg("event handler:"..code)
  handlers[code](self, obj)
end

local client1 = makeClient(hostname, port, onEvent)
print("client1:",client1)
client1:connect()
client1:sendHello()

function abort()
  dbg("timeout, failing")
  client1:disconnect()
end
handlers["srHello"] = function ()
  print("got hello reply")
  client1:register("username", "password", "email@example.com")
end
handlers["srRegisterReply"] = function ()
  client1:login("username","password")
end
handlers["srLoginReply"] = function ()
  client1:scCreateClub(true, "club name", "password", 30);
end
handlers["srCreateClubReply"] = function (self, obj)
  dump("made club", obj);
  if obj.club.members[0].unlimited_limit then
    set_success(true)
  end
end

setTimeout(abort, 0, 5);
return true
