var net = require('net');
var fs = require('fs');

var p = require("node-protobuf").Protobuf;

var protoreader = require('.././protoreader');

var pb = new p(fs.readFileSync("../../message.desc"))
var codes = require('../ServerCodes');

protoreader.init(pb,codes,[codes.scHello]);

function Core(handle) {
	if (!(this instanceof Core)) return new Core(handle);
	this.socket = net.connect(12345,'dev-server.chipuppoker.com',function cb2() {
	});
	this.reader = new protoreader(this.socket,this);
	this.handle = handle;
	//this.socket.on('end',function () {
		//this.log('connection lost');
		//process.exit();
	//}.bind(this));
	this.codes = codes;
}
Core.pb = pb;
Core.prototype.error = function (err) {
	console.log('internal error',err);
	process.exit();
}
Core.prototype.log = function () {
	console.log.apply(console,arguments);
}
Core.prototype.debugHandle = function (code,args) {
	var obj;
	switch (code) {
	case this.codes.srHello:
		obj = pb.Parse(args,'Poker.HelloReply');
		break;
	case this.codes.srRegisterReply:
		obj = pb.Parse(args,'Poker.RegisterReply');
		break;
	case this.codes.srLoginReply:
		obj = pb.Parse(args,'Poker.LoginReply');
		break;
	default:
		console.log('unhandled method',code);
	}
	if (obj) console.log(this.codes.reverse[code],obj);
	return obj;
}
Core.prototype.reply = protoreader.reply;
module.exports = Core;
