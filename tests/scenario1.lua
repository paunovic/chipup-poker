local hostname,port = ...
local clubseq;
local clubid;
local bot1_id, bot2_id;
local handlers = {}
local idle = 0;

--print("need to connect to "..hostname..":"..port)

function onEvent(client, code, obj)
  idle = 0;
  if code == "seTableStatus" then
  else
    dbg(" IN ".. client.name ..": "..code)
  end
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
client1.leaving = 0;
client2.leaving = 0;

handlers.srHello = function (self, obj)
  self:sendMessage("scRegister", { displayName = self.name, password = "password", email = self.name .. "@example.com" })
end
handlers.srRegisterReply = function (self, obj)
  dbg("register reply#".. self.name);
  self:sendMessage("scLogin", { username = self.name, password = "password" });
end

handlers.srLogout = function (self)
  self:disconnect();
  set_success(true);
end

client1:connect()
client2:connect()

client1:sendMessage("scHello",{ debug = false, appcode = "acDelphiWindows" });
client2:sendMessage("scHello",{ debug = false, appcode = "acDelphiWindows" });

function tick()
  idle = idle + 1;
  if idle > 10 then
    dbg("timeout, failing")
    client1:disconnect()
    client2:disconnect()
  else
    setTimeout(tick, 0, 1);
  end
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
  self.state = 0;
  if self.name == "bot1" then
    self:sendMessage("scCreateClub", { is_private = true, name = "club name", password = "password", rake = 0, buyin_reset = 30 });
    bot1_id = obj.self._id;
  else
    bot2_id = obj.self._id
    a_ready2 = true;
    check_a();
  end
end

handlers.srJoinClubReply = function (self, obj)
  dump("join club reply", obj);
  if obj.status == "csSuccess" then
    assert_eq(false, obj.club.members[1].unlimited_limit);
    assert_eq(false, obj.club.members[2].unlimited_limit);

    if not obj.club.members[1].status == "msActive" then return end
    if not obj.club.members[2].status == "msActive" then return end
    client1:sendMessage("scCreateGame", { club_mongoid = clubid, game_type = "gtHoldem", game_limit = "glNoLimit", blinds = "gb5x5", seats = 5, gamename = "TBL#1" });
  end
end

local club_once = true;
handlers.seClubChange = function (self, obj)
  dump("club change", obj);
  if self.name == "bot1" and club_once then
    if 2 == #obj.members then
      club_once = false;
      client1:sendMessage("scApproveClubMember", { club_mongo_id = clubid, player_mongo_id = bot2_id, flag = true });
    else
      client1:sendMessage("scSetPlayerLimit", { clubid = clubid, userid = bot1_id, limit = 100000, unlimited = false; });
    end
  end
end

handlers.srCreateClubReply = function (self, obj)
  clubseq = obj.club.seq;
  clubid = obj.club._id;

  local c = {};
  c.unlimited_default_balance = false;
  c.rake = obj.club.rake;
  c._id = obj.club._id;
  c.buyin_reset = obj.club.buyin_reset;
  c.default_balance_limit = obj.club.default_balance_limit;
  c.name = obj.club.name;
  c.password = "password";
  self:sendMessage("scChangeClubDetails", c);
end

handlers.srPlayerLimitOk = function (self, obj)
  a_ready1 = true;
  check_a();
end

handlers.srCreateGameOk = function (self, obj)
  client1:sendMessage("scTableJoin", { _id = obj._id });
  client2:sendMessage("scTableJoin", { _id = obj._id });
end

function extractCards(input)
  local output = {};
  for i=1, #input do
    local c = input:byte(i);
    output[i] = c;
  end
  return output;
end

handlers.seTableStatus = function (self, obj)
  --if self.leaving == 2 and self.seat == 1 then dump(self.name .. " leaving " .. self.leaving, obj); end
  if self.leaving == 1 then
    for k,v in ipairs(obj.seats) do
      if v.seat_index == self.seat then
        if v.status == "psOutOfPlay" then
          dbg(self.name.." need to leave");
          self:sendMessage("scTableStandUp", { _id = obj.table_mongo_id });
          self.leaving = 2;
        end
      end
    end
  end
  local show_events = true;
  if obj.handid then
    --if obj.state == "tsPreFlop" then
    --  show_events = true;
    --elseif obj.state == "tsFlop" then
    --  show_events = true;
    --elseif obj.state == "tsTurn" then
    --  show_events = true;
    --elseif obj.state == "tsRiver" then
    --  show_events = true;
    --else
      dbg(self.name.." TS state#"..obj.handid..":"..obj.state);
    --end
  else
    dbg(self.name.." TS state#:"..obj.state);
  end
  if show_events and obj.events then
    for k,v in ipairs(obj.events) do
      dbg(k.." = " .. v.event);
      if v.event == "teDealing" then
        for k,v in ipairs(obj.seats) do
          if v.seat_index == self.seat then
            local extracted = extractCards(v.cards);
            assert_eq(2, #extracted);
            if self.seat == 1 then
              assert_eq(12, extracted[1]);
              assert_eq(15, extracted[2]);
            else
              assert_eq(16, extracted[1]);
              assert_eq(19, extracted[2]);
            end
          end
        end
      elseif v.event == "teFlop" then
        dump("teFlop bets", v.bets);
        assert_eq(1, #v.cards);
        local extracted = extractCards(v.cards[1]);
        assert_eq(20, extracted[1]);
        assert_eq(24, extracted[2]);
        assert_eq(28, extracted[3]);
      elseif v.event == "teTurn" then
        dump("teTurn bets", v.bets);
        assert_eq(1, #v.cards);
        local extracted = extractCards(v.cards[1]);
        assert_eq(32, extracted[1]);
      elseif v.event == "teRiver" then
        dump("teRiver bets", v.bets);
        assert_eq(1, #v.cards);
        local extracted = extractCards(v.cards[1]);
        assert_eq(40, extracted[1]);
      elseif v.event == "teStandUp" then
        if v.seat == self.seat then
          dbg(self.name.." has stood up, leaving");
          self:sendMessage("scTableLeave", { _id = obj.table_mongo_id });
          setTimeout(function ()
            self:sendMessage("scLogout");
          end, 0, 2)
        end
      elseif v.event == "teWinning" then
        if self.name == "bot1" then
          dump("entire win packet", obj);
        end
        self:sendMessage("scTableSitOutNextHand", { table_mongo_id = obj.table_mongo_id, flag = true });
        self.leaving = 1;
      end
    end
  end
  --dump(self.name.." table status", obj);
  if self.state == 0 and obj.state == "tsIdle" then
    if self.sitting then
      self:sendMessage("scTablePlayNow", { _id = obj.table_mongo_id });
      self.state = 1;
    else
      self:sendMessage("scTableSit", { game_id = obj.table_mongo_id, seat_index = self.seat, chips = 20000 });
      self.sitting = true;
    end
  elseif (obj.state == "tsPreFlop" or obj.state == "tsFlop" or obj.state == "tsTurn" or obj.state == "tsRiver") and self.state == 1 then
    if self.seat == obj.current_seat then
      dbg(self.name.." my turn!");
      self:sendMessage("scPutChips", { table_mongo_id = obj.table_mongo_id, chip_amount = obj.minimum_bet, current_state = obj.state });
    end
  end
end
handlers.srTableStandUpOk = function (self, obj)
  handlers.seTableStatus(self, obj);
end

handlers.srHandHistoryMsg = function (self, obj)
  --dump("srHandHistoryMsg", obj);
end

handlers.srTableStatsReply = function (self, obj)
  --dump("srTableStatsReply", obj);
end

setTimeout(tick, 0, 1);
return true
