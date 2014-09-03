var fs = require('fs');
var p = require("node-protobuf");
var net = require('net');
var colors = require('colors');
var util = require('util');
var express = require('express');
var http = require('http');
var MongoClient = require('mongodb').MongoClient
var crypto = require('crypto');
var assert = require('assert');
var tls = require('tls');

var Protoreader = require('./protoreader');
var codes = require('./BackendFunctions');
var MongoStore = require('./mongoStore');

var pb = new p(fs.readFileSync("../message.desc"));
Protoreader.init(pb,codes);

var ProtobufUtil = require('./ProtobufUtil');
var pbu = new ProtobufUtil(pb,'Poker.RpcMessage',codes);

var clients = [];

var logs = {};

var options = {
	key: fs.readFileSync('key.pem'),
	cert: fs.readFileSync('cert.pem')
};

//var server = net.createServer(function (socket) {
var server = tls.createServer(options,function listener(socket) {
	var handler = new Client(socket);
});
var cactiServer = require('net').createServer(stats_server);
var app = express();
var masterServer = http.createServer(app);
var IO = require('socket.io').listen(masterServer,{log:false});
var sessionStore;
var restarting = false;
var main_server;
var bots = {};
var buffer = [];
var autoRestart = true;
Error.stackTraceLimit = 20;
var retry = 20;

MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	assert.ifError(err);
	sessionStore = new MongoStore(db,'master_sessions');
	app.set('view engine','jade');
	app.use(express.bodyParser({uploadDir:'./upload'}));
	app.use(express.cookieParser());
	app.use(express.session({secret:'ahQu6eey',key:'master',store:sessionStore,cookie:{maxAge:60 * 60 * 1000}})); // 1 hour
	app.post('/',function (req,res) {
		var username = req.body.username;
		var password = req.body.password;
		console.log('checking auth %s/%s',username,password);
		db.collection('admin').findOne({username:username},function (err,adminRow) {
			console.log('adminRow:%j',adminRow);
			if (adminRow) {
				if (!adminRow.salt) {
					if (adminRow.password == password) {
						req.session.authed = true;
						req.session.username = adminRow.username;
						res.render('master_index');
						return;
					}
				} else {
					var hasher = crypto.createHash('sha256');
					hasher.update(adminRow.salt.buffer);
					hasher.update(password);
					var hash = hasher.digest();
					if (hash.toString('hex') == adminRow.password.buffer.toString('hex')) {
						req.session.authed = true;
						req.session.username = adminRow.username;
						res.writeHead(302,{Location:'/'});
						res.end('sucess');
						return;
					} else {
						res.end('no match');
						return;
					}
				}
			}
			res.end('fail');
		});
	});
	app.get('/',function (req,res) {
		console.log(req.session);
		if (req.session.authed) {
			res.render('master_index');
		} else {
			res.render('master_login');
		}
	});
	masterServer.listen(8080);
	startImHub();
});
IO.set('authorization',function (handshakeData,callback) {
	var test = require('./node_modules/express/node_modules/connect');
	var cookieModule = require('./node_modules/express/node_modules/cookie');
	if (handshakeData.headers.cookie) {
		var cookies = cookieModule.parse(handshakeData.headers.cookie);
		var parsed = test.utils.parseSignedCookies(cookies,'ahQu6eey');
	}
	if (parsed && parsed.master) {
		sessionStore.get(parsed.master,function (err,session) {
			callback(null,session.authed);
		});
	}
});
IO.on('connection',function (socket) {
	var livelink = new ControlLink();
	var activeServer = 'dev';
	socket.on('start',function () {
		if (main_server) {
			console.log('server already up');
		} else if (restarting) {
		} else {
			autoRestart = true;
			startImHub();
		}
	});
	socket.on('stop',function () {
		console.log('stop time?');
		if (main_server) {
			autoRestart = false;
			main_server.kill();
		} else {
			console.log('server already down');
		}
	});
	socket.on('restart',function () {
		autoRestart = true;
		if (main_server) {
			main_server.kill();
		} else if (restarting) {
		} else {
			startImHub();
		}
	});
	socket.on('startBot',function (obj) {
		if (activeServer == 'dev') {
			obj.target = 'dev';
			startBot(obj);
		} else livelink.startBot(obj);
	});
	socket.on('stopBot',function (obj) {
		if (obj.target == 'dev') stopBot(obj.name);
		else livelink.stopBot(obj.name);
	});
	socket.on('disconnect',function () {
		livelink.disconnect();
	});
	socket.on('changeServer',function (id) {
		activeServer = id;
	});
	for (var key in bots) {
		socket.emit('botStarted',bots[key].config);
	}
});
function startBot(obj) {
	console.log(obj);
	if (bots[obj.name]) {
		console.log('bot already running');
	} else {
		bots[obj.name] = require('child_process').fork('./testclient.js',[obj.mode,obj.name,'127.0.0.1']);
		bots[obj.name].on('exit',function () {
			delete bots[obj.name];
			IO.sockets.emit('botStopped',{name:obj.name,target:'dev'});
			sendAll(codes.srBotStopped,{name:obj.name,target:obj.target},'Backend.StopBot');
		});
		bots[obj.name].config = obj;
		IO.sockets.emit('botStarted',obj);
		sendAll(codes.srBotStarted,obj,'Backend.StartBot');
	}
}
function stopBot(name) {
	if (bots[name]) {
		bots[name].send({cmd:'stop'});
	}
}
function ControlLink() {
	this.socket = tls.connect(45508,'chipuppoker.com',{ca:[fs.readFileSync('live-cert.pem')],servername:'server.chipuppoker.com'},function (){});
	this.socket.on('error',function (err) {
		console.log('unable to control/connect to live',err);
	});
	this.socket.on('data',pbu.createOnDataListenerFn(this.handle.bind(this),console.log));
}
ControlLink.prototype.handle = function (err,method,args) {
	var params;
	function forward(data) {
		// FIXME, forward to websocket
		IO.sockets.emit('live',data);
	}
	switch (method) {
	case codes.PerClientMsgEvent:
		params = pb.Parse(args,'Backend.PerClientMsg');
		params.type = 'conn';
		forward(params);
		break;
	case codes.PerGameMsgEvent:
		params = pb.Parse(args,'Backend.PerGameMsg');
		params.type = 'game';
		forward(params);
		break;
	case codes.srBotStarted:
		params = pb.Parse(args,'Backend.StartBot');
		params.target = 'live';
		IO.sockets.emit('botStarted',params);
		break;
	case codes.srBotStopped:
		params = pb.Parse(args,'Backend.StopBot');
		IO.sockets.emit('botStopped',{name:params.name,target:'live'});
		break;
	default:
		console.log('controllink',method,args);
	}
}
ControlLink.prototype.startBot = function (obj) {
	this.reply(codes.scStartBot,obj,'Backend.StartBot');
}
ControlLink.prototype.stopBot = function (name) {
	this.reply(codes.scStopBot,{name:name},'Backend.StopBot');
}
ControlLink.prototype.disconnect = function () {
	this.socket.destroy();
}
ControlLink.prototype.reply = function (code,data,type) {
	var hidden = [];
	pbu.reply(this.socket,hidden,console.log,code,data,type);
}
function Client(sockin) {
	this.socket = sockin;
	this.reader = new Protoreader(this.socket,this.handle.bind(this),this.log.bind(this),this.log.bind(this));
	this.reply(codes.Hello);
	for (var key in bots) {
		sendAll(codes.srBotStarted,bots[key].config,'Backend.StartBot');
	}
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
Client.prototype.reply = function (code,data,type) {
	this.reader.reply(code,data,type);
}
Client.prototype.log = function log(format) {
	var out = Array.prototype.slice.call(arguments);
	//out.unshift(new Date().toString()+":");
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	out.unshift('Master:');
	if (this.name) out.unshift(this.name);
	//if (this.name != 'client3') return;
	console.log.apply(this,out);
}
Client.prototype.handle = function (code,data) {
	var params;
	console.log(code,data);
	switch (code) {
	case codes.StartServer:
		if (main_server) {
			console.log('server already up');
		} else if (restarting) {
		} else {
			autoRestart = true;
			startImHub();
		}
		break;
	case codes.StopServer:
		if (main_server) {
			autoRestart = false;
			main_server.kill();
		} else {
			console.log('server already down');
		}
		break;
	case codes.RestartServer:
		autoRestart = true;
		if (main_server) {
			main_server.kill();
		} else if (restarting) {
		} else {
			startImHub();
		}
		break;
	case codes.scStartBot:
		params = pb.Parse(data,'Backend.StartBot')
		params.target = 'live';
		startBot(params);
		break;
	case codes.scStopBot:
		params = pb.Parse(data,'Backend.StopBot');
		stopBot(params.name);
		break;
	}
}
server.listen(45508);
cactiServer.listen(45509);
function getLog(name) {
	if (!logs[name]) {
		logs[name] = fs.createWriteStream('logs/'+name+'.log');
	}
	return logs[name];
}
function sendAll(code,data,type) {
	for (var x=0; x<clients.length; x++) {
		clients[x].reply(code,data,type);
	}
}
function startImHub() {
	restarting = false;
	for (var x=0; x<clients.length; x++) {
		clients[x].reply(codes.Starting);
	}
	main_server = require('child_process').fork('./server.js');
	//im_hub.stdout.setEncoding('utf8');
	//im_hub.stdout.on('data',readStdOut);
	//im_hub.stderr.setEncoding('utf8');
	//im_hub.stderr.on('data',readStdErr);
	//process.stdin.pipe(im_hub.stdin);
	if (process.platform == 'linux') {
		//setTimeout(function () { im_hub.kill('SIGUSR1'); },100);
	}
	main_server.on('message',function (msg) {
		IO.sockets.emit('message',msg); // FIXME, filter it more
		buffer.push(msg);
		switch (msg.type) {
		case 'control':
			if (msg.cmd == 'autooff') autoRestart = false;
			break;
		case 'conn':
			var display = [ msg.ts,msg.nick+':' ];
			var log = [ msg.ts,msg.nick,msg.ip,msg.connid ];
			//console.log(msg.ts,msg.nick,util.inspect(msg.objects,{colors:true}));
			for (var x=0; x<msg.objects.length; x++) {
				display.push(util.inspect(msg.objects[x],{colors:true}));
				msg.objects[x]= JSON.stringify(msg.objects[x]);
				log.push(msg.objects[x]);
			}
			//console.log.apply(console,display);
			for (var x=0; x<clients.length; x++) {
				clients[x].reply(codes.PerClientMsgEvent,msg,'Backend.PerClientMsg');
			}
			getLog('client_'+msg.nick).write(log.join(',')+'\n');
			break;
		case 'game':
			var display = [ msg.ts,msg.name+':' ];
			var log = [ msg.ts,msg.name ];
			for (var x=0; x<msg.objects.length; x++) {
				display.push(util.inspect(msg.objects[x],{colors:true}));
				msg.objects[x] = JSON.stringify(msg.objects[x]);
				log.push(msg.objects[x]);
			}
			//console.log(msg.ts,msg.name+':',util.inspect(msg.objects,{colors:true}));
			//console.log.apply(console,display);
			for (var x=0; x<clients.length; x++) {
				clients[x].reply(codes.PerGameMsgEvent,msg,'Backend.PerGameMsg');
			}
			getLog('game_'+msg.name).write(log.join(',')+'\n');
			break;
		case 'global':
			break;
		default:
			var string = msg.msg;
			delete msg.msg;
			console.log('child message'.green,util.inspect(msg,{colors:true}),string);
			msg.msg = string;
			for (var x=0; x<clients.length; x++) {
				clients[x].reply(codes.GlobalMsgEvent,msg,'Backend.GlobalMsg');
			}
			getLog('global').write(string+'\n');
		}
		while (buffer.length > 200) {
			//console.log('shrinking buffer');
			buffer.shift();
		}
	});
	//process.stdin.resume();
	main_server.on('exit',restartImHub);
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
	main_server = null;
	if (autoRestart) {
	//var db = require('./db').makeIt();
	//db.verbose = true;
	//var fulllog = buffer.join('');
	//console.log(fulllog.length,'restartImHub',code);
		console.log('restarting...');
	//db.doQuery('INSERT INTO im_hub_crashes (buffer,code) VALUES (?,?)',[fulllog,code]);
	//db.db.end();
		restarting = true;
		setTimeout(startImHub,1000);
	} else {
		console.log('leaving server down');
	}
	buffer = [];
}
function cactiStats() {
	var mem = process.memoryUsage();
	var data = { };
	var msg = []
	for (x in data) {
		msg.push(x+':'+data[x]);
	}
	for (x in mem) {
		msg.push(x+':'+mem[x]);
	}
	return msg.join(' ');
}
function stats_server(c) {
	c.write(cactiStats());
	c.end();
}
