"use strict";
var net = require('net');
var p = require("node-protobuf");
var fs = require("fs");
var assert = require('assert');

var pb = new p(fs.readFileSync("../message.desc"))
var codes = require('./ServerCodes');
var ProtobufUtil = require('./ProtobufUtil');
var pbu = new ProtobufUtil(pb,'Poker.RpcMessage',codes);

function Client(username) {
	this.name = username;
	this.socket = net.connect(12345,'dev-server.chipuppoker.com',function cb2() {});
	this.socket.on('data',pbu.createOnDataListenerFn(this.handle.bind(this),this.log.bind(this)));
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
Client.prototype.log = function log(first) {
	if (first == 'arguments not in buffer yet') return;
	var out = Array.prototype.slice.call(arguments);
	out.unshift(new Date().toString()+":");
	if (this.name) out.unshift(this.name);
	console.log.apply(this,out);
}
Client.prototype.handle = function (err,code,buffer) {
	var params;
	assert.ifError(err);
	if ([codes.srPong,codes.seTableStatus,codes.srHandHistoryMsg,codes.srTableStatsReply,codes.srLoginReply].indexOf(code) == -1) this.log(codes.reverse[code],buffer);
	switch (code) {
	case codes.srHello:
		this.reply(codes.scLogin,{username:this.name,password:'password'},'Poker.LoginParams');
		break;
	case codes.srLoginReply:
		params = pb.Parse(buffer,'Poker.LoginReply');
		console.log('reconnect:%j',params.reconnect_tables);
		this.self = params.self;
		this.userid = this.self._id.toString('hex');
		for (var x=0; x<params.reconnect_tables.length; x++) {
			var tbl = params.reconnect_tables[x];
			for (var y=0; y<tbl.seats.length; y++) {
				console.log(tbl.seats[y].player_mongo_id.toString('hex'),this.userid);
				if (tbl.seats[y].player_mongo_id.toString('hex') == this.userid) {
					if (tbl.seats[y].autoplay || true) {
						console.log('need to play now');
						this.reply(codes.scTablePlayNow,{_id:tbl.table_mongo_id},'Poker.Game');
						this.reply(codes.scSplitTableCards,{table_mongo_id:tbl.table_mongo_id,flag:true},'Poker.TableBoolFlag');
					}
				}
			}
		}
		break
	case codes.seTableStatus:
		params = pb.Parse(buffer,'Poker.TableStatus');
		console.log('events',params.events);
		if (params.locked) return;
		switch (params.state) {
		case 'tsPreFlop':
		case 'tsFlop':
		case 'tsTurn':
		case 'tsRiver':
			var activeSeat;
			for (var x=0; x<params.seats.length; x++) if (params.seats[x].seat_index == params.current_seat) activeSeat = params.seats[x];
			if (activeSeat && activeSeat.player_mongo_id.toString('hex') == this.userid) {
				if (activeSeat.autoplay) {
					this.log('its me, but in auto mode');
				} else {
					//console.log(activeSeat);
					//console.log(params.minimum_bet);
					//console.log(params.bets);
					if (params.minimum_bet > (activeSeat.chips + params.bets[params.current_seat]) ) params.minimum_bet = activeSeat.chips + params.bets[params.current_seat];
					setTimeout(function () {
						this.reply(codes.scPutChips,{table_mongo_id:params.table_mongo_id, chip_amount:params.minimum_bet, current_state:params.state},'Poker.PutChips');
					}.bind(this),5000);
				}
			}
			break;
		case 'tsWinning':
			//this.reply(codes.scShowCards,{_id:params.table_mongo_id},'Poker.Game');
			break;
		default:
			this.log(params.state);
		}
		break;
	case codes.srNotImplemented:
		this.log(buffer.toString('utf8'));
		break;
	case codes.seSecondaryLoginDetected:
		this.socket.destroy();
		break;
	case codes.seTournamentPlayerFinished:
		params = pb.parse(buffer,'Poker.TournamentPlayerFinished');
		console.log(params);
		break;
	case codes.srTournamentDetails:
		params = pb.parse(buffer,'Poker.TournamentInfo');
		for (var x=0; x<params.games.length; x++) {
			console.log('game %d count %d',x,params.games[x].sitting);
		}
		break;
	case codes.seChat:
		params = pb.parse(buffer,'Poker.ChatEvent');
		console.log(params);
		break;
	}
}
Client.prototype.reply = function (code,data,type) {
	var hidden = [codes.scPing];
	pbu.reply(this.socket,hidden,this.log.bind(this),code,data,type);
}
for (var x=2; x<process.argv.length; x++) {
	new Client(process.argv[x]);
}
