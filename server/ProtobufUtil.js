'use strict';

module.exports = ProtobufUtil;

function ProtobufUtil(protobuf, schema,codes) {
	this.protobuf = protobuf;
	this.schema = schema;
	this.codes = codes;
}

ProtobufUtil.prototype.createOnDataListenerFn = function (callback, logger) {
	logger = typeof logger !== 'undefined' ?  logger : console.log;
	var buffer = new Buffer(0);
	var self = this;

	return function (chunk) {
		buffer = Buffer.concat([buffer, chunk]);

		while (buffer.length >= 2) {
			var headerSize = buffer.readInt16LE(0);

			if (headerSize === 0) {
				buffer = buffer.slice(2);
				continue;
			}

			if (buffer.length < 2 + headerSize) {
				logger('header not in buffer yet');
				break;
			}

			var headerUnparsed = buffer.slice(2, 2 + headerSize);

			try {
				var header = self.protobuf.Parse(headerUnparsed, self.schema);

				if (!header.DataSize)
					header.DataSize = 0;

				if (buffer.length < (2 + headerSize + header.DataSize)) {
					logger('arguments not in buffer yet');
					break;
				}

				var args = buffer.slice(2 + headerSize, 2 + headerSize + header.DataSize);
				callback(null, header.MethodId, args, 'raw');
				buffer = buffer.slice(2 + headerSize + header.DataSize);
			} catch (e) {
				callback(e);
			}
		}
	};
};


ProtobufUtil.prototype.encode = function (code, message, type) {
	code = parseInt(code);
	var args, dataSize = 0;

	if (message) {
		args = type === 'raw' ? message : this.protobuf.Serialize(message, type);
		dataSize = args.length;
	}

	var object = {
		MethodId: code,
		DataSize: dataSize
	};
	var header = this.protobuf.Serialize(object, this.schema);
	var encodedMessage = new Buffer(2 + header.length + dataSize);
	encodedMessage.writeUInt16LE(header.length, 0);
	header.copy(encodedMessage, 2);

	if (dataSize > 0)
		args.copy(encodedMessage, 2 + header.length);

	return encodedMessage;
};

ProtobufUtil.prototype.reply = function (socket,hidden,log,code,message,type) {
	var packet = this.encode(code,message,type)
	var alldone = socket.write(packet);
	if (!alldone) {
		if (socket._handle) log('partial message write %d %s', socket.bufferSize,util.inspect({a:socket._handle.writeQueueSize,b:socket._writableState.length}));
	}
	if (socket._writableState.length > (256 * 1024)) {
		error('sendq overflow');
	}
	if (!hidden || hidden.indexOf(code) === -1) {
		log('sent %d bytes for code %s', packet.length, this.codes.reverse[code]);
	}
};

