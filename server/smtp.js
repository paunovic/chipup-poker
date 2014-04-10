var dns = require('dns');
var net = require('net');
var Reader = require('./reader').reader;
module.exports = SmtpConnection;
function SmtpConnection() {
}
SmtpConnection.prototype.sendMail = function verify(email,body,callback) {
	parts = email.split('@');
	if (parts[1].trim() == 'server.com') {
		console.log('ding',body);
		callback(null,true);
		return;
	}
	if (parts.length != 2) return callback(null,false);
	dns.resolveMx(parts[1],function (err,ret) {
		if (err) return callback(err);
		if (ret.length == 0) return callback(undefined,false);
		console.log('cb2',err,ret);
		// ret[0].exchange
		var state = 0;
		var socket = net.createConnection({host:'127.0.0.1',port:25});
		var reader = new Reader(socket,function handleLine(line) {
			console.log('line is',line);
			var parts = line.split(' ');
			var code = parseInt(parts[0]);
			switch (code) {
			case 220:
				socket.write("MAIL FROM:service@chipuppoker.com\r\n");
				break;
			case 250:
				if (state == 0) {
					socket.write("RCPT TO:"+email+"\r\n");
					state++;
				} else if (state == 1) {
					socket.write("DATA\r\n");
					state++;
				} else {
					socket.write("QUIT\r\n");
					callback(null,true);
				}
				break;
			case 354:
				socket.write(body);
				socket.write("\r\n.\r\n");
				break;
			}
		});
	});
	console.log('verify',email);
}
if (require.main === module) {
	var test = new SmtpConnection();
	test.sendMail('clever@echodsi.com','Subject: test\r\n\r\nbody',function cb(err,ret) {
		console.log('cb',err,ret);
	});
}
