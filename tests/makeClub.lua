local hostname,port = ...
handlers = {}

function onEvent(self, code, obj)
  dbg("event handler:"..code)
  handlers[code](self, obj)
end

local client1 = makeClient(hostname, port, onEvent)
local state = 0;
print("client1:",client1)
client1:connect()
client1:sendHello()

function abort()
  client1:disconnect()
end
handlers["srHello"] = function ()
  print("got hello reply")
  client1:register("username", "password", "email@example.com")
end
handlers["srRegisterReply"] = function ()
  client1:login("username","password")
end
handlers["srLoginReply"] = function (self, obj)
  if state == 0 then
    client1:scCreateClub(true, "club name", "password", 30);
  else
    if obj.clubs[1].members[1].unlimited_limit == true then
      set_success(true);
    end
  end
end
handlers["srCreateClubReply"] = function (self, obj)
  dump("made club", obj);
  if obj.club.members[1].unlimited_limit then
    self:sendMessage("scLogout");
  end
end
handlers.srLogout = function (self)
  state = 1;
  client1:login("username","password");
end
--set_success(true)

setTimeout(abort, 0, 5);
return true
