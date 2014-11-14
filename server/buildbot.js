var https = require('http');
var globalCookies = {};
var config = require('./config');
module.exports.forceBuild = forceBuild;
module.exports.doLogin = doLogin;
function forceBuild(builder,rev) {
	var msg = {forcescheduler:'force',reason:'force build',branch:'',revision:rev,repository:'',project:''};
	for (var x=1; x<5; x++) {
		msg['property'+x+'_name'] = '';
		msg['property'+x+'_value'] = '';
	}
	var data = [];
	for (var key in msg) {
		data.push(key+'='+escape(msg[key]));
	}
	var body = new Buffer(data.join('&'));
	console.log(body.toString());
	var headers = {'Content-Length':body.length, Cookie: [],'Content-Type':'application/x-www-form-urlencoded'};
	for (var key in globalCookies) {
		headers.Cookie.push(key+'='+globalCookies[key]);
	}
	var req = https.request({host:'buildbot.chipuppoker.com',method:'POST',path:'/builders/'+builder+'/force',headers:headers,auth:'node:Eiwae5ah'},function (reply) {
		console.log(reply.headers);
		console.log(reply.statusCode);
		req.on('data',function (chunk) {
			console.log(chunk);
		});
		req.on('error',function (err) {
			console.log('http error doing buildbot force:',err);
		});
	});
	req.write(body);
	req.end();
}
function doLogin(cb) {
	var body = new Buffer('username=node&passwd='+config.bbpassword);
	var req = https.request({host:'buildbot.chipuppoker.com',method:'POST',path:'/login',headers:{'Content-Length':body.length,'Content-Type':'application/x-www-form-urlencoded'},auth:'node:Eiwae5ah'},function (reply) {
		console.log(reply.headers);
		console.log(reply.statusCode);
		req.on('data',function (chunk) {
			console.log(chunk);
		});
		req.on('error',function (err) {
			console.log('http error logging into buildbot:',err);
		});
		var cookies = reply.headers['set-cookie'];
		if (!cookies) return cb();
		for (var x=0; x<cookies.length; x++) {
			var c = cookies[x].split(';')[0].split('=');
			globalCookies[c[0]] = c[1];
		}
		cb();
	});
	req.write(body);
	req.end();
}
