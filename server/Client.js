'use strict';
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