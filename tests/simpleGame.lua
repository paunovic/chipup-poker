local hostname,port = ...
local clubseq;
local clubid;
local bot2_id;
local handlers = {}

print("need to connect to "..hostname..":"..port)

function onEvent(client, code, obj)
  dbg(" IN ".. client.name ..": "..code)
  if client.handlers and client.handlers[code] then
    client.handlers[code](client, obj);
  elseif handlers[code] then
    handlers[code](client, obj)
  else
    print("handler not found for "..code)
  end
end

local client1 = makeClient(hostname, port, onEvent)
local client2 = makeClient(hostname, port, onEvent)
client1.name = "bot1";
client2.name = "bot2";
client1.seat = 1;
client2.seat = 2;

handlers.srHello = function (self, obj)
  self:sendMessage("scRegister", { displayName = self.name, password = "password", email = self.name .. "@example.com" })
end
handlers.srRegisterReply = function (self, obj)
  dbg("register reply#".. self.name);
  self:sendMessage("scLogin", { username = self.name, password = "password" });
end

client1:connect()
client2:connect()

client1:sendMessage("scHello",{ debug = false, appcode = "acDelphiWindows" });
client2:sendMessage("scHello",{ debug = false, appcode = "acDelphiWindows" });

function abort()
  dbg("timeout, failing")
  client1:disconnect()
  client2:disconnect()
end
local a_ready1 = false;
local a_ready2 = false;
function check_a()
  if a_ready1 and a_ready2 then
    client2:sendMessage("scJoinClub", { seq = clubseq, password = "password" });
  end
end
handlers["srLoginReply"] = function (self, obj)
  dbg("login reply#".. self.name);
  if self.name == "bot1" then
    self:sendMessage("scCreateClub", { is_private = true, name = "club name", password = "password", rake = 0, buyin_reset = 30 });
  else
    bot2_id = obj.self._id
    a_ready2 = true;
    check_a();
  end
end

handlers.srJoinClubReply = function (self, obj)
  if obj.status == "csSuccess" then
    dbg("clubid size " .. #clubid .. " string " .. clubid);
    client1:sendMessage("scCreateGame", { club_mongoid = clubid, game_type = "gtHoldem", game_limit = "glNoLimit", blinds = "gb5x5", seats = 5, gamename = "TBL#1" });
  end
end

local club_once = true;
handlers.seClubChange = function (self, obj)
  if self.name == "bot1" and club_once then
    club_once = false;
    client1:sendMessage("scApproveClubMember", { club_mongo_id = clubid, player_mongo_id = bot2_id, flag = true });
  end
end

handlers.srCreateClubReply = function (self, obj)
  clubseq = obj.club.seq;
  clubid = obj.club._id;
  a_ready1 = true;
  check_a();
end

handlers.srCreateGameOk = function (self, obj)
  dump("made game", obj);
  client1:sendMessage("scTableJoin", { _id = obj._id });
  client2:sendMessage("scTableJoin", { _id = obj._id });
end

local state = 0;
handlers.seTableStatus = function (self, obj)
  dump("table status", obj);
  if state == 0 and obj.state == "tsIdle" then
    self:sendMessage("scTableSit", { game_id = obj.table_mongo_id, seat_index = self.seat, chips = 200 });
  end
end

function onEvent(code, obj, id)
end

setTimeout(abort, 0, 5);
return true

