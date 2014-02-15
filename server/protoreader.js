module.exports = protoreader;
var pb,codes;
function protoreader(socket,handler) {
	if (!(this instanceof protoreader)) return new protoreader(socket,handler);
	this.socket = socket;
	this.handler = handler;
	this.buffer = null;
	function process_packet() {
		if (this.buffer.length < 2) {
			console.log('size prefix not in buffer yet');
			return;
		}
		var headersize = this.buffer.readInt16LE(0);
		if (this.buffer.length < (2+headersize)) {
			console.log('header not in buffer yet',headersize);
			return false;
		}
		//console.log('\nheader size:',headersize,this.buffer);
		var header = this.buffer.slice(2,2+headersize);
		try {
			header = pb.Parse(header,'Poker.RpcMessage');
			if (!header.DataSize) header.DataSize = 0;
			//console.log('header is',header);
		} catch (e) {
			console.log(header);
			this.handler.error(e);
			return false;
		}
		if (this.buffer.length < (2+headersize+header.DataSize)) {
			console.log('arguments not in buffer yet');
			return false;
		}
		var args = this.buffer.slice(2+headersize,2+headersize+header.DataSize);
		try {
			this.handler.handle(header.MethodId,args);
		} catch (e) {
			this.handler.error(e);
		}
		this.buffer = this.buffer.slice(2+headersize+header.DataSize);
		return true;
	}
	this.socket.on('data',function (chunk) {
		if (this.buffer) {
			this.buffer = Buffer.concat([this.buffer,chunk]);
		}
		else this.buffer = chunk;
		while ((this.buffer.length > 0) && process_packet.call(this)) { }
		if (this.buffer.length > 0) this.handler.log('remaining data:',this.buffer);
	}.bind(this));
}
protoreader.init = function init(input,mapping) {
	pb = input;
	codes = mapping;
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
	if (!alldone) this.log('partial message write');
	//console.log('header out:',header);
	//console.log(object);
	if ([codes.PerClientMsgEvent,codes.seChat,codes.scTableSit,codes.scTableJoin,codes.scLogin,codes.scStatus,codes.seGameChange].indexOf(code) != -1) {
	} else if (code == 100) this.log('sent '+datasize+' bytes for code '+code,message);
	else this.log('sent '+datasize+' bytes for code '+codes.reverse[code]);
	//console.log(message);
}

