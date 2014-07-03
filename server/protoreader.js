var util = require('util');

module.exports = protoreader;
var pb,codes,hidden;
function protoreader(socket,handler,error) {
	if (!(this instanceof protoreader)) return new protoreader(socket,handler,error);
	this.socket = socket;
	this.handler = handler;
	this.buffer = null;
	this.error = error;
	var self = this;

	function process_packet() {
		if (self.buffer.length < 2) {
			console.log('size prefix not in buffer yet');
			return;
		}
		var headersize = self.buffer.readInt16LE(0);
		if (self.buffer.length < (2 + headersize)) {
			console.log('header not in buffer yet', headersize);
			return false;
		}

		if (headersize > 0) {
			var header = self.buffer.slice(2, 2 + headersize);
			try {
				header = pb.Parse(header,'Poker.RpcMessage');
				if (!header.DataSize) header.DataSize = 0;
			} catch (e) {
				console.log(header);
				self.error(e);
				return false;
			}
			if (self.buffer.length < (2 + headersize + header.DataSize)) {
				console.log('arguments not in buffer yet');
				return false;
			}
			var args = self.buffer.slice(2+headersize,2+headersize+header.DataSize);
			self.handler(header.MethodId,args);
			self.buffer = self.buffer.slice(2+headersize+header.DataSize);
		} else {
			self.buffer = self.buffer.slice(2);
		}
		return true;
	}

	self.socket.on('data',function (chunk) {
		if (self.buffer) {
			self.buffer = Buffer.concat([self.buffer,chunk]);
		}
		else self.buffer = chunk;
		while ((self.buffer.length > 0) && process_packet) { }
	});
}
protoreader.init = function init(input,mapping,hiddenin) {
	pb = input;
	codes = mapping;
	hidden = hiddenin;
}
protoreader.reply = function reply(code,message,type) {
	code = parseInt(code);
	var args;
	var datasize = 0;
	if (type == 'raw') {
		args = message;
		datasize = args.length;
	} else if (message) {
		args = pb.Serialize(message,type);
		datasize = args.length;
	}
	var object = { MethodId:code, DataSize:datasize };
	var header = pb.Serialize(object, "Poker.RpcMessage");
	var totalsize = 2 + header.length + datasize;
	var messageOut = new Buffer(totalsize);
	messageOut.writeUInt16LE(header.length,0);
	header.copy(messageOut,2);
	if (datasize > 0) args.copy(messageOut,2+header.length);
	var alldone = this.socket.write(messageOut);
	if (!alldone) {
		if (this.socket._handle) this.log('partial message write %d %s',this.socket.bufferSize,util.inspect({a:this.socket._handle.writeQueueSize,b:this.socket._writableState.length}));
	}
	if (this.socket._writableState.length > (256 * 1024)) {
		this.error('sendq overflow');
	}
	//console.log('header out:',header);
	//console.log(object);
	if (!hidden || hidden.indexOf(code) == -1) {
		this.log('sent %d bytes for code %s',datasize,codes.reverse[code]);
	}
	//console.log(message);
}

