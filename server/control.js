var net = require('net');
var p = require("node-protobuf").Protobuf;
var fs = require('fs');
var colors = require('colors');
var util = require('util');

var protoreader = require('./protoreader');
var codes = require('./BackendFunctions');

var pb = new p(fs.readFileSync("../message.desc"));
protoreader.init(pb,codes);

var socket = new Client('127.0.0.1',45508);
function Client(ip,port) {
	this.socket = net.connect(port,ip,function (){});
	this.reader = new protoreader(this.socket,this);
	this.socket.on('end',function () {
		this.log('connection lost');
		process.stdin.pause();
	}.bind(this));
}
Client.prototype.handle = function (code,data) {
	switch (code) {
	case codes.PerClientMsgEvent:
		var msg = pb.Parse(data,'Backend.PerClientMsg');
		msg.objects.unshift(msg.nick+':');
		msg.objects.unshift(msg.ts);
		console.log.apply(this,msg.objects);
		//console.log(msg.ts,msg.nick,msg.objects);
		break;
	case codes.PerGameMsgEvent:
		var msg = pb.Parse(data,'Backend.PerGameMsg');
		msg.objects.unshift(msg.name+':');
		msg.objects.unshift(msg.ts);
		console.log.apply(this,msg.objects);
		break;
	case codes.GlobalMsgEvent:
		var msg = pb.Parse(data,'Backend.GlobalMsg');
		console.log('global message'.green,util.inspect(msg,{colors:true}));
		break;
	default:
		this.log(codes.reverse[code],data);
	}
}
Client.prototype.error = function (e) {
	console.error(e);
}
Client.prototype.log = function log() {
	var out = Array.prototype.slice.call(arguments);
	out.unshift(new Date().toString()+":");
	if (this.name) out.unshift(this.name);
	//if (this.name != 'client3') return;
	console.log.apply(this,out);
}
Client.prototype.reply = protoreader.reply;
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
var mainmenu = { start:function () {
	socket.reply(codes.StartServer);
},stop:function () {
	socket.reply(codes.StopServer);
},restart:function () {
	socket.reply(codes.RestartServer);
},quit:function () {
	process.exit();
}};
doMenu(mainmenu);
