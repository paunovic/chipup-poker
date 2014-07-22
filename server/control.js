var net = require('net');
var p = require("node-protobuf");
var fs = require('fs');
var colors = require('colors');
var util = require('util');
var tls = require('tls');

var Protoreader = require('./protoreader');
var codes = require('./BackendFunctions');

var pb = new p(fs.readFileSync("../message.desc"));
Protoreader.init(pb,codes,[codes.GlobalMsgEvent]);

var autoRestart = false;

function Client(ip,port) {
	this.socket = tls.connect(port,ip,{ca:[fs.readFileSync('cert.pem')],servername:'master.chipuppoker.com'},function (){});
	this.reader = new Protoreader(this.socket,this.handle.bind(this),this.error.bind(this),this.log.bind(this));
	this.socket.on('end',function () {
		this.log('connection lost');
		process.stdin.pause();
	}.bind(this));
}
Client.prototype.handle = function (code,data) {
	switch (code) {
	case codes.PerClientMsgEvent:
		var msg = pb.Parse(data,'Backend.PerClientMsg');
		//msg.objects.unshift(msg.nick+':');
		//msg.objects.unshift(msg.ts);
		//console.log.apply(this,msg.objects);
		var display = [ msg.ts,msg.nick+':' ];
		for (var x=0; x<msg.objects.length; x++) {
			display.push(util.inspect(JSON.parse(msg.objects[x]),{colors:true}));
		}
		console.log.apply(console,display);
		//console.log(msg.ts,msg.nick,msg.objects);
		break;
	case codes.PerGameMsgEvent:
		var msg = pb.Parse(data,'Backend.PerGameMsg');
		var display = [ msg.ts,msg.name+':' ];
		for (var x=0; x<msg.objects.length; x++) {
			display.push(util.inspect(JSON.parse(msg.objects[x]),{colors:true}));
		}
		console.log.apply(console,display);
		break;
	case codes.GlobalMsgEvent:
		var msg = pb.Parse(data,'Backend.GlobalMsg');
		console.log('global message'.green,util.inspect(msg,{colors:true}));
		break;
	case codes.Starting:
		if (autoRestart) process.exit();
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
Client.prototype.reply = function (code,data,type) {
	this.reader.reply(code,data,type);
}
var socket = new Client('127.0.0.1',45508);
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
if (process.argv.length > 2) {
	if (process.argv[2] == 'restart') {
		autoRestart = true;
		socket.reply(codes.RestartServer);
	}
}
