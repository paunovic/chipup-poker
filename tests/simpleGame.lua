local hostname,port = ...

print("need to connect to "..hostname..":"..port)

local client1 = makeClient(hostname, port, 1)
local client2 = makeClient(hostname, port, 2)
client1:connect()
--client2:connect()

client1:sendMessage("scHello",{ debug = false, appcode = "acDelphiWindows" });
--client2:sendMessage("scHello",{ debug = false, appcode = "acDelphiWindows" });

function abort()
  print("timeout, failing")
  client1:disconnect()
  --client2:disconnect()
end
handlers = {}
handlers["srHello"] = function (obj, id)
  print("got hello reply#"..id)
  if (id == 1) then
    client1:sendMessage("scRegister", { displayName = "bot1", password = "password", email = "bot1@example.com" });
  else
    client2:sendMessage("scRegister", { displayName = "bot2", password = "password", email = "bot2@example.com" });
  end
end
handlers["srRegisterReply"] = function (obj, id)
  print("register reply#"..id);
  if id == 1 then
    client1:sendMessage("scLogin", { username = "bot1", password = "password" });
  else
    client2:sendMessage("scLogin", { username = "bot2", password = "password" });
  end
end
local a_ready1 = false;
local a_ready2 = false;
function check_a()
  if a_ready1 and a_ready2 then
    client2:sendMessage("scJoinClub", { seq = clubseq });
  end
end
handlers["srLoginReply"] = function (obj, id)
  dump("login reply", obj)
  print("login reply#"..id);
  if id == 1 then
    client1:sendMessage("scCreateClub", { is_private = true, name = "club name", password = "password", rake = 0, buyin_reset = 30 });
  else
    a_ready2 = true;
    check_a();
  end
end
local clubseq;
handlers["srCreateClubReply"] = function (obj, id)
  dump("made club", obj)
  clubseq = obj.seq;
  a_ready1 = true;
  check_a();
end

function joingame()
  for k,g in ipairs(msg.games) do
    if g.gamename == "test table" then
      join_game(g._id);
    end
  end
end
function onEvent(code, obj, id)
  if handlers[code] then
    handlers[code](obj, id)
  else
    print("handler not found for "..code)
  end
end

function join_game(id)
  client1:sendMessage("scTableJoin", { _id = id});
end

setTimeout(abort, 0, 30);
return true

