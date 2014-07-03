module.exports = protoreader;

var util = require('util');
var pb,codes,hidden, buffer;

function protoreader(socket,handler,error) {
	if (!(this instanceof protoreader)) return new protoreader(socket,handler,error);
	this.socket = socket;
	this.handler = handler;
	buffer = null;
	this.error = error;
	function process_packet() {
		if (buffer.length < 2) {
			console.log('size prefix not in buffer yet');
			return;
		}
		var headersize = buffer.readInt16LE(0);
		if (buffer.length < (2 + headersize)) {
			console.log('header not in buffer yet', headersize);
			return false;
		}
		if (headersize > 0) {
			var header = buffer.slice(2, 2 + headersize);
			try {
				header = pb.Parse(header,'Poker.RpcMessage');
				if (!header.DataSize) header.DataSize = 0;
			} catch (e) {
				console.log(header);
				this.error(e);
				return false;
			}
			if (buffer.length < (2 + headersize + header.DataSize)) {
				console.log('arguments not in buffer yet');
				return false;
			}
			var args = buffer.slice(2 + headersize, 2 + headersize + header.DataSize);
			this.handler(header.MethodId,args);
			buffer = buffer.slice(2 + headersize + header.DataSize);
		} else {
			buffer = buffer.slice(2);
		}
		return true;
	}

	this.socket.on('data',function (chunk) {
		if (buffer) {
			buffer = Buffer.concat([buffer, chunk]);
		}
		else buffer = chunk;
		while ((buffer.length > 0) && process_packet.call(this)) { }
	}.bind(this));
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

	if ([codes.PerClientMsgEvent,codes.seChat,codes.scTableSit,codes.scTableJoin,codes.scLogin,codes.scStatus,codes.seGameChange,codes.PerGameMsgEvent].indexOf(code) != -1) {
	} else if (hidden && hidden.indexOf(code) != -1) {
	} else if (code == 100) this.log('sent '+datasize+' bytes for code '+code,message);
	else this.log('sent %d bytes for code %s',datasize,codes.reverse[code]);
}

