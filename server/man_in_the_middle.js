'use strict';
var net = require('net');
var util = require('util');

exports.createManInTheMiddleServer = function (pu, realServerPort, fakeServerPort, recordCallback) {
	var server = net.createServer(function (clientToFakeServerSocket) {
		var fakeToRealServerSocket = net.connect(realServerPort, function () {
			var clientToServerSpy = createRecordAndForwardFn(fakeToRealServerSocket, pu, recordCallback);
			clientToFakeServerSocket.on('data', pu.createOnDataListenerFn(clientToServerSpy));

			var serverToClientSpy = createRecordAndForwardFn(clientToFakeServerSocket, pu, recordCallback);
			fakeToRealServerSocket.on('data', pu.createOnDataListenerFn(serverToClientSpy));

			server.on('close', function () {
				fakeToRealServerSocket.destroy();
			});
		});
	}).listen(fakeServerPort);

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