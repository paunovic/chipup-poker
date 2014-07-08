'use strict';
var net = require('net');
var util = require('util');

var C2S = 'client to server direction';
var S2C = 'server to client direction';

var socketCount = 0;
exports.createManInTheMiddleServer = function (pu, realServerPort, fakeServerPort, recorderCallback) {
	var server = net.createServer(function (clientToFakeServerSocket) {
		var socketId = socketCount++;
		var fakeToRealServerSocket = net.connect(realServerPort, function () {
			var clientToServerSpy = createRecordAndForwardFn(fakeToRealServerSocket, pu, recorderCallback, socketId, C2S);
			clientToFakeServerSocket.on('data', pu.createOnDataListenerFn(clientToServerSpy));

			var serverToClientSpy = createRecordAndForwardFn(clientToFakeServerSocket, pu, recorderCallback, socketId, S2C);
			fakeToRealServerSocket.on('data', pu.createOnDataListenerFn(serverToClientSpy));

			server.on('close', function () {
				fakeToRealServerSocket.destroy();
			});
		});
	}).listen(fakeServerPort);

	return server;
}

function createRecordAndForwardFn(destinationSocket, protobufUtil, recorderCallback, socketId, direction) {
	return function (err, methodId, args, type) {
		if (err) {
			console.log(err.name + ": " + err.message);
		}
		recorderCallback(methodId, args, type, socketId, direction);
		var encodedMessage = protobufUtil.encode(methodId, args, type);

		if (!destinationSocket.write(encodedMessage) && destinationSocket._handle) {
			console.log(
				'partial message write %d %s',
				destinationSocket.bufferSize,
				util.inspect({
					a: destinationSocket._handle.writeQueueSize,
					b: destinationSocket._writableState.length
				})
			);
		}

		if (destinationSocket._writableState.length > (256 * 1024))
			console.log('send overflow');
	};
}