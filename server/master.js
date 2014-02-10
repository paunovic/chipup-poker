var fs = require('fs');
var p = require("node-protobuf").Protobuf;
var net = require('net');
var colors = require('colors');
var util = require('util');

var protoreader = require('./protoreader');
var codes = require('./BackendFunctions');

var pb = new p(fs.readFileSync("../message.desc"));
protoreader.init(pb,codes);

var clients = [];

var server = net.createServer(function (socket) {
	var handler = new Client(socket);
});
function Client(sockin) {
	this.socket = sockin;
	this.reader = new protoreader(this.socket,this);
	this.reply(codes.Hello);
	this.socket.on('end',function () {
		this.log('connection lost');
		this.remove();
	}.bind(this));
	this.socket.on('error',function () {
		this.log('client lost due to error');
		this.remove();
	}.bind(this));
	clients.push(this);
}
Client.prototype.remove = function () {
	var idx = clients.indexOf(this);
	clients.splice(idx,1);
}
Client.prototype.reply = protoreader.reply;
Client.prototype.log = function log() {
	var out = Array.prototype.slice.call(arguments);
	//out.unshift(new Date().toString()+":");
	out.unshift('Master:');
	if (this.name) out.unshift(this.name);
	//if (this.name != 'client3') return;
	console.log.apply(this,out);
}
Client.prototype.handle = function (code,data) {
	console.log(code,data);
	switch (code) {
	case codes.StartServer:
		if (im_hub) {
			console.log('server already up');
		} else {
			autoRestart = true;
			startImHub();
		}
		break;
	case codes.StopServer:
		if (im_hub) {
			autoRestart = false;
			im_hub.kill();
		} else {
			console.log('server already down');
		}
		break;
	case codes.RestartServer:
		autoRestart = true;
		if (im_hub) {
			im_hub.kill();
		} else {
			startImHub();
		}
		break;
	}
}
server.listen(45508);
var im_hub;
var buffer = [];
var autoRestart = true;
Error.stackTraceLimit = 20;
var retry = 20;
function startImHub() {
	for (var x=0; x<clients.length; x++) {
		clients[x].reply(codes.Starting);
	}
	im_hub = require('child_process').fork('./server.js');
	//im_hub.stdout.setEncoding('utf8');
	//im_hub.stdout.on('data',readStdOut);
	//im_hub.stderr.setEncoding('utf8');
	//im_hub.stderr.on('data',readStdErr);
	//process.stdin.pipe(im_hub.stdin);
	im_hub.on('message',function (msg) {
		buffer.push(msg);
		switch (msg.type) {
		case 'conn':
			console.log(msg.ts,msg.nick,util.inspect(msg.objects,{colors:true}));
			for (var x=0; x<msg.objects.length; x++) {
				if (typeof msg.objects[x] == 'object') msg.objects[x]= util.inspect(msg.objects[x]);
			}
			for (var x=0; x<clients.length; x++) {
				clients[x].reply(codes.PerClientMsgEvent,msg,'Backend.PerClientMsg');
			}
			break;
		default:
			var string = msg.msg;
			delete msg.msg;
			console.log('child message'.green,util.inspect(msg,{colors:true}),string);
			msg.msg = string;
			for (var x=0; x<clients.length; x++) {
				clients[x].reply(codes.GlobalMsgEvent,msg,'Backend.GlobalMsg');
			}
		}
		while (buffer.length > 200) buffer.shift();
	});
	//process.stdin.resume();
	im_hub.on('exit',restartImHub);
}
function readStdOut(data) {
	buffer.push(data);
	while (buffer.length > 200) buffer.shift();
	process.stdout.write('stdout:'+data);
}
function readStdErr(data) {
	buffer.push(data);
	while (buffer.length > 200) buffer.shift();
	process.stdout.write('stderr:'.red+data);
}
function restartImHub(code) {
	for (var x=0; x<clients.length; x++) {
		clients[x].reply(codes.Stopping);
	}
	im_hub = null;
	if (autoRestart) {
	//var db = require('./db').makeIt();
	//db.verbose = true;
	//var fulllog = buffer.join('');
	//console.log(fulllog.length,'restartImHub',code);
		console.log('restarting...');
	//db.doQuery('INSERT INTO im_hub_crashes (buffer,code) VALUES (?,?)',[fulllog,code]);
	//db.db.end();
		setTimeout(startImHub,1000);
	} else {
		console.log('leaving server down');
	}
	buffer = [];
}
startImHub();
