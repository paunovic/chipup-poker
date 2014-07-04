var util = require('util');

module.exports = Protoreader;
var pb, codes, hidden;
var SCHEMA = 'Poker.RpcMessage';

function Protoreader(socket,handler,error) {
	if (!(this instanceof Protoreader)) return new Protoreader(socket,handler,error);
	this.handler = handler;
	this.buffer = new Buffer(0);
	this.error = error;
	socket.on('data', this._ondata.bind(this));
}
Protoreader.prototype._ondata = function (chunk) {
	this.buffer = Buffer.concat([this.buffer, chunk]);

	while (this.buffer.length >= 0) {
		var headersize = this.buffer.readInt16LE(0);
		if (this.buffer.length < (2 + headersize)) {
			console.log('header not in buffer yet', headersize);
			break;
		}

		this.buffer = this.buffer.slice(2);

		if (headersize > 0) {
			var header = this.buffer.slice(headersize);
			try {
				header = pb.Parse(header, SCHEMA);
				if (!header.DataSize) header.DataSize = 0;
			} catch (e) {
				console.log(header);
				this.error(e);
				break;
			}
			if (this.buffer.length < (headersize + header.DataSize)) {
				console.log('arguments not in buffer yet');
				break;
			}
			var args = this.buffer.slice(headersize, headersize + header.DataSize);
			this.handler(header.MethodId, args);
			this.buffer = this.buffer.slice(headersize + header.DataSize);
		}
	}
	//if (this.buffer.length > 0) this.handler.log('remaining data:',this.buffer);
}
Protoreader.init = function init(input, mapping, hiddenin) {
	pb = input;
	codes = mapping;
	hidden = hiddenin;
}
Protoreader.reply = function reply(code,message,type) {
	code = parseInt(code);
	var args;
	if (type == 'raw') {
		args = message;
	} else if (message) {
		args = pb.Serialize(message,type);
	}
	datasize = args.length;
	var object = { MethodId: code, DataSize: datasize };
	var header = pb.Serialize(object, SCHEMA);
	var totalsize = 2 + header.length + datasize;
	var messageOut = new Buffer(totalsize);
	messageOut.writeUInt16LE(header.length,0);
	header.copy(messageOut, 2);
	if (datasize > 0) args.copy(messageOut, 2 + header.length);
	var alldone = this.socket.write(messageOut);
	if (!alldone) {
		if (this.socket._handle) this.log('partial message write %d %s', this.socket.bufferSize,util.inspect({a:this.socket._handle.writeQueueSize,b:this.socket._writableState.length}));
	}
	if (this.socket._writableState.length > (256 * 1024)) {
		this.error('sendq overflow');
	}
	if (!hidden || hidden.indexOf(code) === -1) {
		this.log('sent %d bytes for code %s', datasize, codes.reverse[code]);
	}
}

