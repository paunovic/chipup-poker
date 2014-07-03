var fs = require('fs');
var p = require("node-protobuf").Protobuf;
var net = require('net');
var colors = require('colors');
var util = require('util');
var express = require('express');
var http = require('http');
var MongoClient = require('mongodb').MongoClient
var crypto = require('crypto');
var assert = require('assert');

var protoreader = require('./protoreader');
var codes = require('./BackendFunctions');
var MongoStore = require('./mongoStore');

var pb = new p(fs.readFileSync("../message.desc"));
protoreader.init(pb,codes);

var clients = [];

var logs = {};

var server = net.createServer(function (socket) {
	var handler = new Client(socket);
});
var cactiServer = require('net').createServer(stats_server);
var app = express();
var masterServer = http.createServer(app);
var io = require('socket.io').listen(masterServer,{log:false});
var sessionStore;
var restarting = false;

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
						res.end('sucess');
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
io.set('authorization',function (handshakeData,callback) {
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
io.on('connection',function (socket) {
	socket.on('start',function () {
		if (im_hub) {
			console.log('server already up');
		} else if (restarting) {
		} else {
			autoRestart = true;
			startImHub();
		}
	});
	socket.on('stop',function () {
		console.log('stop time?');
		if (im_hub) {
			autoRestart = false;
			im_hub.kill();
		} else {
			console.log('server already down');
		}
	});
	socket.on('restart',function () {
		autoRestart = true;
		if (im_hub) {
			im_hub.kill();
		} else if (restarting) {
		} else {
			startImHub();
		}
	});
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
	console.log(code,data);
	switch (code) {
	case codes.StartServer:
		if (im_hub) {
			console.log('server already up');
		} else if (restarting) {
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
		} else if (restarting) {
		} else {
			startImHub();
		}
		break;
	}
}
server.listen(45508);
cactiServer.listen(45509);
var im_hub;
var buffer = [];
var autoRestart = true;
Error.stackTraceLimit = 20;
var retry = 20;
function getLog(name) {
	if (!logs[name]) {
		logs[name] = fs.createWriteStream('logs/'+name+'.log');
	}
	return logs[name];
}
function startImHub() {
	restarting = false;
	for (var x=0; x<clients.length; x++) {
		clients[x].reply(codes.Starting);
	}
	im_hub = require('child_process').fork('./server.js');
	//im_hub.stdout.setEncoding('utf8');
	//im_hub.stdout.on('data',readStdOut);
	//im_hub.stderr.setEncoding('utf8');
	//im_hub.stderr.on('data',readStdErr);
	//process.stdin.pipe(im_hub.stdin);
	if (process.platform == 'linux') {
		//setTimeout(function () { im_hub.kill('SIGUSR1'); },100);
	}
	im_hub.on('message',function (msg) {
		io.sockets.emit('message',msg);
		buffer.push(msg);
		switch (msg.type) {
		case 'control':
			if (msg.cmd == 'autooff') autoRestart = false;
			break;
		case 'conn':
			var display = [ msg.ts,msg.nick+':' ];
			var log = [ msg.ts,msg.nick,msg.connid ];
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
