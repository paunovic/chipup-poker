var fs = require("fs");
var p = require("node-protobuf").Protobuf;
var net = require('net');
var pb = new p(fs.readFileSync("../message.desc"))
var codes = require('./ServerCodes');
var Protoreader = require('./protoreader');
var MongoClient = require('mongodb').MongoClient;
var async = require('async');
var colors = require('colors');
var Hand = require('./deck').Hand;

Protoreader.init(pb,codes);

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
		if (require.main === module) {
			console.log(process.argv);
			var mode = process.argv[2];
			var autoconfig = {moves:[],autoRandom:{call:16,fold:2,raise:8,standup:1},speed:[0,0],players:5, buyins:[100000,100000,100000,100000,100000]};
			var prefix = process.argv[3];
			if (prefix) autoconfig.prefix = prefix;
			switch (mode) {
			case 'menu':
				tests = [ function sidepot(cb) {
					testmenu(cb,{players:4,prefix:prefix});
				} ];
				break;
			case 'sidepot':
				tests = [ function sidepot(cb) {
					testmenu(cb,{moves:['raise 1000','raise 500','call'],players:3,buyins:[10005,1005,500],initialFold:true,rounds:3});
				} ];
				break;
			case 'fastbot':
				tests = [ function autobot(cb) {
					autoconfig.speed = [10,0];
					testmenu(cb,autoconfig);
				} ];
				break;
			case 'slowbot':
				tests = [ function autobot(cb) {
					autoconfig.speed = [1000,500];
					testmenu(cb,autoconfig);
				} ];
				break;
			case 'slowmobot':
				tests = [ function autobot(cb) {
					autoconfig.speed = [5000,60000];
					testmenu(cb,autoconfig);
				} ];
				break;
			}
			async.series(tests,function allgood(err) {
				if (err) {
					console.log('error',err);
				} else {
					console.log('all done');
				}
				conn.close();
			});
		}
	});
	clubs = db.collection('clubs');
	conn.close();
});

function Client(handle) {
	this.socket = net.connect(12345,'dev-server.chipuppoker.com',function cb2() {
	});
	this.handle = handle;
	this.reader = new Protoreader(this.socket,this.handle.bind(this),this.error.bind(this),this.log.bind(this));
	this.socket.on('end',function () {
		this.log('connection lost');
		process.exit();
	}.bind(this));
	this.pinger = setInterval(this.ping.bind(this),30000);
	this.reply(codes.scHello,{debug:false},'Poker.HelloParams');
}
Client.prototype.ping = function () {
	this.reply(codes.scPing,{uptime:process.uptime()},'Poker.PingParams');
}
Client.prototype.reply = function (code,data,type) {
	this.reader.reply(code,data,type);
}
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
Client.prototype.getSeat = function getSeat(seat) {
	var seats = this.tableStatus.seats;
	for (var x=0; x<seats.length; x++) {
		if (seats && seats[x].seat == seat) return seats[x];
	}
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
	var clients = [];
	var prefix = 'client';
	if (config && config.prefix) prefix = config.prefix;
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
		if (config.speed[0] == 0) return func();

		if (timer) clearTimeout(timer);
		timer = setTimeout(func,(config.speed[1] * Math.random())+config.speed[0]);
	}
	function showMoves(conn,actseq) {
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
				conn.reply(codes.scPutChips,{table_mongo_id:gameid, chip_amount: oldbet, current_state:ts.state},'Poker.PutChips');
			}
		}
		if (oldbet < conn.tableStatus.minimum_bet) {
			moves.call = function () {
				console.log('doing call from '+oldbet+'->'+conn.tableStatus.minimum_bet+'(adding '+(conn.tableStatus.minimum_bet-oldbet)+')');
				var obj = {table_mongo_id:gameid, chip_amount:conn.tableStatus.minimum_bet, current_state:ts.state};
				console.log(obj);
				conn.reply(codes.scPutChips,obj,'Poker.PutChips');
			}
			moves.call.info = oldbet+'->'+conn.tableStatus.minimum_bet+'(adding '+(conn.tableStatus.minimum_bet-oldbet)+')';
		}
		moves.raise = function (args) {
			var newbet = parseInt(args[0]);
			conn.log(actseq+':doing raise from '+oldbet+'->'+newbet+'(adding '+(newbet-oldbet)+')');
			conn.reply(codes.scPutChips,{table_mongo_id:gameid, chip_amount:newbet, current_state:ts.state},'Poker.PutChips');
		}
		var ts = conn.tableStatus;
		console.log('flop:%s turn:%s river:%s locked:%s seq:%d dealer:%s handid:%d state:%s',bufToCards(ts.flop),bufToCards(ts.turn),bufToCards(ts.river),ts.locked,ts.seq,ts.dealer,ts.handid,ts.state);
		if (conn.tableStatus.locked) {
			console.log('table locked');
		} else {
			if (config && config.initialFold) {
				if (['psOutOfHand','psOutOfPlay'].indexOf(conn.tableStatus.seats[2].status) != -1) {
					return doit(moves.fold);
				}
			}
			if (autoMoves.length) {
				var move = autoMoves.shift();
				var words = move.split(' ');
				var next = words.shift();
				if (moves[next]) {
					console.log('%d AUTO %s'.red,ts.seq,next);
					return moves[next](words);
				} console.log('BAD AUTO',next);
			}
			if (randomMoves) {
				for (var y=0; y<10; y++) {
					var rand = Math.random();
					console.log('%d AUTO %s',ts.seq,rand);
					for (var x=0; x<randomMoves.length; x++) {
						if ((randomMoves[x].min < rand) && (randomMoves[x].max > rand)) {
							var next = randomMoves[x].move;
							console.log('%d %d AUTO %s',ts.seq,ts.current_seat,next);
							if (next == 'call') {
								var maxchips = conn.getSeat(conn.seat).chips;
								conn.log('oldbet',oldbet,'max',maxchips);
								var newbet = conn.tableStatus.minimum_bet;
								if (maxchips < (newbet - oldbet)) newbet = oldbet + maxchips;
								return doit(function () {
									moves.raise([newbet]);
								});
							} else if (moves[next]) {
								if (next == 'raise') {
									var maxchips = conn.getSeat(conn.seat).chips;
									console.log('oldbet',oldbet,'max',maxchips);
									var newbet = conn.tableStatus.minimum_raise;
									if (maxchips < (newbet - oldbet)) newbet = oldbet + maxchips;
									return doit(function () {
										moves.raise([newbet]);
									});
								} else if (next == 'standup') {
									doit(function() {
										setTimeout(function () {
											conn.log('buying in for ',conn.buyin);
											conn.reply(codes.scTableSit,{game_id:gameid,seat_index:conn.seat,chips:conn.buyin},'Poker.TableSit');
										},500);
										moves[next]();
									});
									return;
								} else return doit(function () {
									moves[next]();
								});
							}
							console.log('BAD AUTO',next);
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
			console.log('flop:%s turn:%s river:%s locked:%s seq:%d dealer:%s handid:%d time:%d',bufToCards(params.flop),bufToCards(params.turn),bufToCards(params.river),params.locked,params.seq,params.dealer,params.handid,params.time);
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
			this.log(msg.red);
			if (msg == 'your not a member of that club') {
				this.reply(codes.scJoinClub,{seq:clubseq,password:'password'},'Poker.Club');
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
			this.reply(codes.scLogin,{username:this.name+'@server.com',password:'password'},'Poker.LoginParams');
			break;
		case codes.seTableStatus:
			var params = pb.Parse(data,'Poker.TableStatus');
			this.tableStatus = params;
			
			checkAndPrint.call(this,params);
			
			if (this.sitting) {
				if ((params.current_seat == this.seat) && (['tsPreFlop','tsFlop','tsTurn','tsRiver'].indexOf(params.state) != -1)) {
					this.log('its my turnB',params.state);
					showMoves(this,params.seq);
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
				showMoves(this,params.seq);
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
		case codes.seGameChange:
			var params = pb.Parse(data,'Poker.Game');
			this.log(params);
			break;
		case codes.srPong:
			var params = pb.Parse(data,'Poker.PingReply');
			break;
		}
	}
	function printcode(code,data) {
		var arr = [codes.srStatus,codes.seTableStatus,codes.srHello,codes.srTableSitOk,codes.srNotImplemented,codes.srTableStatsReply,codes.seGameChange,codes.srPong];
		if (arr.indexOf(code) == -1) this.log('handle',codes.reverse[code],data);
		//console.log(code,arr);
	}
	var madeclients = false;
	function testregisterhandle(code,data) {
		printcode.call(this,code,data);
		switch (code) {
		case codes.srLoginReply:
			var params = pb.Parse(data,'Poker.LoginReply');
			if (params.login_status == 'lrInvalid') {
				this.reply(codes.scRegister,{email:this.name+'@server.com',password:'password',displayName:this.name},'Poker.RegisterParams');
				return;
			}
			if (params.login_status != 'lrSuccess') {
				this.log(params);
				this.socket.destroy();
				conn.close();
				return;
			}
			parseStatusMain.call(this,params.status);
				//this.reply(codes.scTableJoin,{_id:gameid},'Poker.Game');
			break;
		case codes.srCreateClubReply:
			var params = pb.Parse(data,'Poker.ClubCommandReply');
			if (params.status != 'csSuccess') {
				this.log(params);
				this.socket.close();
				return;
			}
			this.log('club seq is',params.club.seq);
			this.reply(codes.scCreateGame,{clubseq: params.club.seq, game_type:'gtHoldem',
				game_limit:'glNoLimit', small_blind:5, big_blind:10, seats:6, gamename:prefix+' testbot game',
				buyin_max:20000, buyin_min:5},'Poker.Game');
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
			if (!madeclients) {
				console.log('clients',(config && config.players) ? config.players : 3);
				for (var x=1; x<((config && config.players) ? config.players : 3); x++) {
					var client2 = new Client(doClient2);
					client2.name = prefix+x;
					client2.seat = x;
					client2.buyin = (config && config.buyins) ? config.buyins.shift() : 10000;
					clients[x] = client2;
				}
				madeclients = true;
			}
			common.call(this,code,data);
			break;
		case codes.seTableEvent:
			var params = pb.Parse(data,'Poker.TableEvent');
			delete params.table_mongo_id;
			this.log(JSON.stringify(params).red);
			if ((params.event == 'teDealing') && config && config.moves) {
				config.rounds--;
				if (config.rounds <= 0) {
					for (var x=0; x<clients.length; x++) {
						clients[x].socket.destroy();
					}
					cb();
					return;
				}
				console.log('reseting moves');
				for (var x=0; x<config.moves.length; x++) {
					autoMoves[x] = config.moves[x];
				}
			}
			break;
		case codes.seTableStatus:
			var params = pb.Parse(data,'Poker.TableStatus');
			for (var i=0; i<params.events.length; i++) {
				console.log('EVENT#%d: %j',i,params.events[i]);
			}
			common.call(this,code,data);
			break;
		default:
			common.call(this,code,data);
		}
	}
	function parseStatusMain(params) {
			var makeit = true;
			for (var x=0; x<params.clubs.length; x++) {
				if (params.clubs[x].name == (prefix + ' testbot club')) {
					clubseq = params.clubs[x].seq;
					makeit = false;
				}
			}
			if (makeit) {
				this.reply(codes.scCreateClub,{is_private:true, name:prefix+' testbot club',password:'password',rake:1},'Poker.Club');
			} else {
				for (var x=0; x<params.games.length; x++) {
					if (params.games[x].gamename == (prefix+' testbot game')) {
						gameid = params.games[x]._id;
					}
				}
				if (gameid) {
					this.reply(codes.scTableJoin,{_id:gameid},'Poker.Game');
					this.joining = true;
				} else {
					this.reply(codes.scCreateGame,{clubseq: clubseq, game_type:'gtHoldem', game_limit:'glNoLimit', blinds:'gb5x10', seats:6, gamename:prefix +' testbot game',buyin_max:20000, buyin_min:5},'Poker.Game');
				}
			}
	}
	function doClient2(code,data) {
		printcode.call(this,code,data);
		switch (code) {
		case codes.srLoginReply:
			var params = pb.Parse(data,'Poker.LoginReply');
			if (params.login_status == 'lrInvalid') {
				this.reply(codes.scRegister,{email:this.name+'@server.com',password:'password',displayName:this.name},'Poker.RegisterParams');
				return;
			}
			if (params.login_status != 'lrSuccess') {
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
	client.name = prefix+'0';
	client.seat = 0;
	client.buyin = (config && config.buyins) ? config.buyins.shift() : 10000;
	clients[0] = client;
}
