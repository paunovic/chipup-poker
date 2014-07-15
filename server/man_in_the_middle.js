/*
TODO: 
[03.06.13] clever: pavle, first minor bug in mitm_test, when a client socket from the testclient is closed
[03.06.37] clever: mitm_test should close the matching socket to the server, and record it similar to a packet from client->server, so it replays the closure the same way
[03.07.01] clever: its minor, because thats the end of the recording, but it hard-crashes instead of closing the recording cleanly
*/
'use strict';
var net = require('net');
var util = require('util');
var directions = require('./directions');

var socketCount = 0;
exports.createManInTheMiddleServer = function (pu, realServerPort, recorderCallback) {
	var server = net.createServer(function (clientToFakeServerSocket) {
		var socketId = socketCount++;
		var fakeToRealServerSocket = net.connect(realServerPort, function () {
			var clientToServerSpy = createRecordAndForwardFn(fakeToRealServerSocket, pu, recorderCallback, socketId, directions.C2S);
			clientToFakeServerSocket.on('data', pu.createOnDataListenerFn(clientToServerSpy));

			var serverToClientSpy = createRecordAndForwardFn(clientToFakeServerSocket, pu, recorderCallback, socketId, directions.S2C);
			fakeToRealServerSocket.on('data', pu.createOnDataListenerFn(serverToClientSpy));

			server.on('close', function () {
				fakeToRealServerSocket.destroy();
			});
		});
	});

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