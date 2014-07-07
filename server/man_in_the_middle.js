'use strict';
var net = require('net');
var util = require('util');

exports.createManInTheMiddleServer = function (protobufUtil, realServerPort, fakeServerPort, recordCallback) {
	var server = net.createServer();

	server.on('connect', function (clientToFakeServerSocket) {
		var fakeToRealServerSocket = net.connect(realServerPort);

		var clientToServerSpy = createRecordAndForwardFn(fakeToRealServerSocket, protobufUtil, recordCallback);
		clientToFakeServerSocket.on('data', s2p.createOnDataListenerFn(protobuf, schema, clientToServerSpy));

		var serverToClientSpy = createRecordAndForwardFn(clientToFakeServerSocket, protobufUtil, recordCallback);
		fakeToRealServerSocket.on('data', s2p.createOnDataListenerFn(protobuf, schema, serverToClientSpy));

		server.on('close', function () {
			fakeToRealServerSocket.destroy();
		});
	});

	server.listen(fakeServerPort);

	return server;
}

function createRecordAndForwardFn(destinationSocket, protobufUtil, recorderCallback) {
	return function (methodId, args) {
		recorderCallback(methodId, args);
		var encodedMessage = protobufUtil.encode(methodId, args);

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