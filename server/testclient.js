var fs = require("fs");
var p = require("node-protobuf").Protobuf;
var net = require('net');
var pb = new p(fs.readFileSync("../message.desc"))
var codes = require('./ServerCodes');
var protoreader = require('./protoreader');
var MongoClient = require('mongodb').MongoClient;
var async = require('async');
var colors = require('colors');
var Hand = require('./deck').Hand;

protoreader.init(pb,codes);

function bufToCards(buf) {
	if (!buf) return 'XXX';
	var hand = { cards: buf.toJSON() };
	return Hand.prototype.prettyPrint.call(hand);
}
MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	if (err) {
		console.log(err);
		process.exit(1);
	}
	conn = db;
	db.collection('users',function (err,collection) {
		if (err) {
			console.log(err);
			process.exit(1);
		}
		allUsers = collection;
		async.series(tests,function allgood(err) {
			if (err) {
				console.log('error',err);
			} else {
				console.log('all done');
			}
			conn.close();
		});
	});
	clubs = db.collection('clubs');
	conn.close();
});

function Client(handle) {
	this.socket = net.connect(12345,'192.168.2.61',function cb2() {
	});
	this.reader = new protoreader(this.socket,this);
	this.handle = handle;
	this.socket.on('end',function () {
		this.log('connection lost');
		process.exit();
	}.bind(this));
}
Client.prototype.reply = protoreader.reply;
function testchathandle(code,data) {
	switch (code) {
	case codes.SR_HELLO:
		var params = pb.Parse(data,'Poker.HelloReply');
		//console.log(params);
		this.reply(codes.CMD_LOGIN,{username:process.argv[2],password:process.argv[3]},'Poker.LoginParams');
		break;
	case codes.SR_LOGIN_OK:
		this.reply(codes.CMD_STATUS);
		break;
	case codes.SR_STATUS:
		var params = pb.Parse(data,'Poker.StatusReply');
		//console.log(params);
		//this.reply(codes.CMD_GETDECK);
		break;
	case codes.EVENT_CHAT:
		var event = pb.Parse(data,'Poker.ChatEvent');
		console.log(event);
		break;
	case codes.SR_DECKREPLY:
		var params = pb.Parse(data,'Poker.GetDeckReply');
		console.log('deck is',params);
		this.socket.destroy();
		break;
	default:
		console.log('handle',code,data);
	}
}
Client.prototype.error = function error(e) {
	this.log('error!',e);
	this.log(e.stack);
	process.exit(1);
}
Client.prototype.log = function log() {
	var out = Array.prototype.slice.call(arguments);
	out.unshift(new Date().toString()+":");
	if (this.name) out.unshift(this.name);
	//if (this.name != 'client3') return;
	console.log.apply(this,out);
}
function testchat () {
	var client = new Client();
	process.stdin.setEncoding('utf8');
	process.stdin.on('data',function (line) {
		client.reply(codes.EVENT_CHAT,{event:'UserMessage',table_id:'Global',msg:{msg:line.trim()}},'Poker.ChatEvent');
	});
	process.stdin.resume();
}
var menusetup = false;
var currentOptions;
function doMenu(options) {
	function printMenu() {
		for (var key in currentOptions) {
			if (currentOptions[key].info) console.log(key.bold+" ("+currentOptions[key].info+")");
			else console.log(key.bold);
		}
		process.stdout.write("> ");
	}
	if (!menusetup) {
		process.stdin.resume();
		process.stdin.setEncoding('utf8');
		process.stdin.on('data',function (chunk) {
			var words = chunk.trim().split(' ');
			var opt = currentOptions[words.shift()];
			if (!opt) {
				console.log('error, valid options are:');
				printMenu();
			} else {
				opt(words);
			}
		});
		menusetup = true;
		process.stdin.on('end',function () {
			process.exit(0);
		});
	}
	currentOptions = options;
	console.log('current options:'.underline);
	printMenu();
}
function testmenu(cb,config) {
	var client2;
	var gameid;
	var clubseq;
	var autoMoves = [];
	var total = 0;
	if (config && config.autoRandom) {
		for (x in config.autoRandom) {
			total += config.autoRandom[x];
		}
		var randomMoves = [];
		var last = 0;
		for (x in config.autoRandom) {
			randomMoves.push({move:x, min:last, max:last+(config.autoRandom[x]/total)});
			last += (config.autoRandom[x]/total);
		}
		console.log('AUTO',randomMoves);
	}
	var timer;
	function doit(func) {
		if (timer) clearTimeout(timer);
		timer = setTimeout(func,(3000 * Math.random())+2000);
	}
	function showMoves(conn) {
		moves = {fold:function() {
			conn.reply(codes.scFold,{_id:gameid},'Poker.Game');
		}};
		moves.standup = function () {
			conn.reply(codes.scTableStandUp,{_id:gameid},'Poker.Game');
		}
		var oldbet = conn.tableStatus.bets[conn.seat];
		if (oldbet === undefined) oldbet = 0;
		if (conn.tableStatus.minimum_bet == oldbet) {
			moves.check = function () {
				console.log('doing check with',oldbet,'all bets are',conn.tableStatus.bets);
				conn.reply(codes.scPutChips,{table_mongo_id:gameid, chip_amount: oldbet},'Poker.PutChips');
			}
		}
		if (oldbet < conn.tableStatus.minimum_bet) {
			moves.call = function () {
				console.log('doing call from '+oldbet+'->'+conn.tableStatus.minimum_bet+'(adding '+(conn.tableStatus.minimum_bet-oldbet)+')');
				var obj = {table_mongo_id:gameid, chip_amount:conn.tableStatus.minimum_bet};
				console.log(obj);
				conn.reply(codes.scPutChips,obj,'Poker.PutChips');
			}
			moves.call.info = oldbet+'->'+conn.tableStatus.minimum_bet+'(adding '+(conn.tableStatus.minimum_bet-oldbet)+')';
		}
		moves.raise = function (args) {
			var newbet = parseInt(args[0]);
			conn.log('doing raise from '+oldbet+'->'+newbet+'(adding '+(newbet-oldbet)+')');
			conn.reply(codes.scPutChips,{table_mongo_id:gameid, chip_amount:newbet},'Poker.PutChips');
		}
		if (conn.tableStatus.locked) {
			console.log('table locked');
		} else {
			if (autoMoves.length) {
				var next = autoMoves.shift();
				if (moves[next]) {
					console.log('AUTO',next);
					return moves[next]();
				} console.log('BAD AUTO',next);
			}
			if (randomMoves) {
				for (var y=0; y<10; y++) {
					var rand = Math.random();
					console.log('AUTO',rand);
					for (var x=0; x<randomMoves.length; x++) {
						if ((randomMoves[x].min < rand) && (randomMoves[x].max > rand)) {
							var next = randomMoves[x].move;
							if (next == 'call') {
								var maxchips = conn.tableStatus.seats[conn.seat].chips;
								conn.log('oldbet',oldbet,'max',maxchips);
								var newbet = conn.tableStatus.minimum_bet;
								if (maxchips < (newbet - oldbet)) newbet = oldbet + maxchips;
								return doit(function () {
									moves.raise([newbet]);
								});
							} else if (moves[next]) {
								console.log('AUTO',next);
								if (next == 'raise') {
									var maxchips = conn.tableStatus.seats[conn.seat].chips;
									console.log('oldbet',oldbet,'max',maxchips);
									var newbet = conn.tableStatus.minimum_bet + 10;
									if (maxchips < (newbet - oldbet)) newbet = oldbet + maxchips;
									return doit(function () {
										moves.raise([newbet]);
									});
								} else return doit(function () {
									moves[next]();
								});
							} console.log('BAD AUTO',next);
						}
					}
				}
			}
			if (config && config.autoCheck && (moves.check)) return moves.check();
			doMenu(moves);
		}
	}
	function checkAndPrint(params) {
		if (params.current_seat == this.seat) {
			console.log('table state:',params.state,'active seat:',params.current_seat,'pots:',params.pots);
			console.log('flop:',bufToCards(params.flop),'turn:',bufToCards(params.turn),'river:',bufToCards(params.river),'locked:',params.locked,'seq:',params.seq,'dealer:',params.dealer);
			if (params.state != 'tsIdle') {
				for (var x=0; x<params.seats.length; x++) {
					var s = params.seats[x];
					var line = 'player#'+s.seat+' state:'+s.status+' bet:'+params.bets[x]+' chips:'+params.seats[x].chips+' cards:'+bufToCards(params.seats[x].cards);
					if (s.seat == params.current_seat) console.log(line.green);
					else console.log(line);
				}
			}
			process.stdout.write("\n");
		}
	}
	function common(code,data) {
		switch (code) {
		case codes.srNotImplemented:
			var msg = data.toString('utf8');
			this.log(msg);
			if (msg == 'your not a member of that club') {
				this.reply(codes.scJoinClub,{seq:clubseq},'Poker.Club');
			}
			break;
		case codes.srJoinClubReply:
			this.reply(codes.scTableSit,{game_id:gameid,seat_index:this.seat,chips:this.buyin},'Poker.TableSit');
			break;
		case codes.srHello:
			this.reply(codes.scLogin,{username:this.name+'@server.com',password:'password'},'Poker.LoginParams');
			//this.reply(codes.scRegister,{email:this.name+'@server.com',password:'password',displayName:this.name},'Poker.RegisterParams');
			break;
		case codes.srRegisterReply:
			var params = pb.Parse(data,'Poker.RegisterReply');
			if (params.status != 'regSuccess') {
				this.log(params);
				this.socket.destroy();
				conn.close();
				return;
			}
			break;
		case codes.seTableStatus:
			var params = pb.Parse(data,'Poker.TableStatus');
			this.tableStatus = params;
			
			checkAndPrint.call(this,params);
			
			if (this.sitting) {
				if ((params.current_seat == this.seat) && (['tsPreFlop','tsFlop','tsTurn','tsRiver'].indexOf(params.state) != -1)) {
					this.log('its my turnB',params.state);
					showMoves(this);
					//this.reply(codes.seChat,{event: 'ceUserMessage',msg:{msg:'my hand sucks, *folding*'},table_id:gameid},'Poker.ChatEvent');
					//this.reply(codes.scFold,{_id:gameid},'Poker.Game');
				} else {
					//this.log('not my turn',params.current_seat,this.seat);
				}
			} else if (this.joining) {
				this.joining = false;
				this.reply(codes.scTableSit,{game_id:gameid,seat_index:this.seat,chips:this.buyin},'Poker.TableSit');
				return;
			}
			break;
		case codes.srTableSitOk:
			this.log('sit ok');
			this.sitting = true;
			var params = pb.Parse(data,'Poker.TableStatus');
			this.tableStatus = params;
			this.reply(codes.scTablePlayNow,{_id:gameid},'Poker.Game');
			if (['tsPreFlop'].indexOf(params.state) == -1) break;
			checkAndPrint.call(this,params);
			if (params.current_seat == this.seat) {
				this.log('its my turnA',this.seat,params.state);
				showMoves(this);
				//this.reply(codes.scFold,{_id:gameid},'Poker.Game');
			} else {
				this.log('not my turn in sit ok',params.current_seat,this.seat,params.state);
			}
			break;
		case codes.seSecondaryLoginDetected:
			this.log('teardown time');
			this.socket.destroy();
			if (conn) {
				conn.close();
				conn = null;
				process.stdin.pause();
			}
			break;
		}
	}
	function printcode(code,data) {
		if ([codes.srStatus,codes.seTableEvent,codes.seTableStatus,codes.srLoginReply,codes.srHello,codes.srTableSitOk,codes.srNotImplemented].indexOf(code) == -1) this.log('handle',codes.reverse[code],data);
	}
	function testregisterhandle(code,data) {
		printcode.call(this,code,data);
		switch (code) {
		case codes.srLoginReply:
			var params = pb.Parse(data,'Poker.LoginReply');
			if (params.status != 'lrSuccess') {
				this.log(params);
				this.socket.destroy();
				conn.close();
				return;
			}
			this.reply(codes.scStatus);
				//this.reply(codes.scTableJoin,{_id:gameid},'Poker.Game');
			break;
		case codes.srStatus:
			var params = pb.Parse(data,'Poker.StatusReply');
			var makeit = true;
			for (var x=0; x<params.clubs.length; x++) {
				if (params.clubs[x].name == 'testbot club') {
					clubseq = params.clubs[x].seq;
					makeit = false;
				}
			}
			if (makeit) {
				this.reply(codes.scCreateClub,{is_private:false, name:'testbot club'},'Poker.Club');
			} else {
				for (var x=0; x<params.games.length; x++) {
					if (params.games[x].gamename == 'testbot game') {
						gameid = params.games[x]._id;
					}
				}
				if (gameid) {
					this.reply(codes.scTableJoin,{_id:gameid},'Poker.Game');
					this.joining = true;
				} else {
					this.reply(codes.scCreateGame,{clubseq: clubseq, game_type:1, game_limit:1, small_blind:5, big_blind:10, seats:6, gamename:'testbot game'},'Poker.Game');
				}
			}
			break;
		case codes.srCreateClubReply:
			var params = pb.Parse(data,'Poker.ClubCommandReply');
			if (params.status != 'csSuccess') {
				this.log(params);
				this.socket.close();
				return;
			}
			this.log('club seq is',params.club.seq);
			this.reply(codes.scCreateGame,{clubseq: params.club.seq, game_type:1, game_limit:1, small_blind:5, big_blind:10, seats:6, gamename:'testbot game'},'Poker.Game');
			break;
		case codes.srCreateGameOk:
			var params = pb.Parse(data,'Poker.Game');
			//this.log(params);
			gameid = params._id;
			this.reply(codes.scTableJoin,{_id:gameid},'Poker.Game');
			this.joining = true;
			this.log('gameid is',gameid);
			break;
		case codes.srTableSitOk:
			var params = pb.Parse(data,'Poker.TableStatus');
			//this.log(params);
			for (var x=1; x<6; x++) {
				var client2 = new Client(doClient2);
				client2.name = 'client'+x;
				client2.seat = x;
				client2.buyin = 10000;
			}
			common.call(this,code,data);
			break;
		case codes.seTableEvent:
			var params = pb.Parse(data,'Poker.TableEvent');
			delete params.table_mongo_id;
			this.log(JSON.stringify(params).red);
			if ((params.event == 'teDealing') && config && config.moves) {
				console.log('reseting moves');
				for (var x=0; x<config.moves.length; x++) {
					autoMoves[x] = config.moves[x];
				}
			}
			break;
		case codes.seTableStatus:
			var params = pb.Parse(data,'Poker.TableStatus');
			common.call(this,code,data);
			break;
		default:
			common.call(this,code,data);
		}
	}
	function doClient2(code,data) {
		printcode.call(this,code,data);
		switch (code) {
		case codes.srLoginReply:
			var params = pb.Parse(data,'Poker.LoginReply');
			if (params.status != 'lrSuccess') {
				this.log(params);
				this.socket.destroy();
				conn.close();
				return;
			}
			this.reply(codes.scTableJoin,{_id:gameid},'Poker.Game');
			this.joining = true;
			break;
		case codes.srTableSitOk:
			var params = pb.Parse(data,'Poker.TableStatus');
			common.call(this,code,data);
			break;
		default:
			common.call(this,code,data);
		}
	}
	var client = new Client(testregisterhandle);
	client.name = 'client0';
	client.seat = 0;
	client.buyin = 10000;
}
function autobot(cb) {
	testmenu(cb,{moves:[],autoRandom:{call:16,fold:1,raise:12}});
}
tests = [ autobot ];
//tests = [ testmenu ];
