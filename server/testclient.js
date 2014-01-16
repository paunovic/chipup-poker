var fs = require("fs");
var p = require("node-protobuf").Protobuf;
var net = require('net');
var pb = new p(fs.readFileSync("../message.desc"))
var codes = require('./ServerCodes');
var protoreader = require('./protoreader');
protoreader.init(pb);

function Client() {
	this.socket = net.connect(12345,'192.168.2.61',function cb2() {
		console.log('connected');
	});
	this.reader = new protoreader(this.socket,this);
}
Client.prototype.reply = protoreader.reply;
Client.prototype.handle = function handle(code,data) {
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
		this.reply(codes.EVENT_CHAT,{event:'UserMessage',table_id:'Global',msg:{msg:'test'}},'Poker.ChatEvent');
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
Client.prototype.log = function log() {
	var out = Array.prototype.slice.call(arguments);
	out.unshift(new Date().toString()+":");
	console.log.apply(this,out);
}
var client = new Client();
process.stdin.setEncoding('utf8');
process.stdin.on('data',function (line) {
	client.reply(codes.EVENT_CHAT,{event:'UserMessage',table_id:'Global',msg:{msg:line.trim()}},'Poker.ChatEvent');
});
process.stdin.resume();
