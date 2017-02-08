var https = require('https');
var rest = require('rest');

function requestTracker(user,pass) {
	this.user = user;
	this.pass = pass;
}
requestTracker.prototype.rest = function test(url,args,cb) {
	rest({path:'https://rt.chipuppoker.com/REST/1.0/'+url,headers:{Cookie:this.auth,Referer:'https://rt.chipuppoker.com/REST/1.0/'},rejectUnauthorized:false,entity:args}).then(function(response) {
		console.log('response: ', response.entity);
		if (cb) cb();
	}).catch(function(e) {
		console.log('rest error',e);
		cb(e);
	});
	return;
}
requestTracker.prototype.login = function login(cb) {
	var postbody = new Buffer("user="+this.user+"&pass="+this.pass);
	var req = https.request({hostname:'rt.chipuppoker.com',method:'POST',path:'/NoAuth/Login.html',
		headers:{
		'Content-Type': 'application/x-www-form-urlencoded',
		'Content-Length':postbody.length
		},
		rejectUnauthorized:false
	},function (req) {
		req.setEncoding('utf8');
		req.on('data',function (data) {
			//console.log('data',data);
		});
		req.on('end',function () {
			this.auth = req.headers['set-cookie'][0].split(';')[0];
			console.log('done',this.auth);
			cb();
		}.bind(this));
	}.bind(this));
	req.write(postbody);
	req.end();
	req.on('error',function (err) {
		console.log('login error',err);
	});
}
requestTracker.prototype.createTicket = function (obj,cb) {
	var out = [];
	for (var key in obj) {
		out.push(key+': '+(obj[key].replace(/\n/g,'\n ')));
	}
	out = out.join('\n');
	var data = 'content='+escape(out);
	console.log(data);
	this.rest('ticket/new',data,cb);
}
//login('root','password');

function postTicket(queue,email,body,cb) {
	console.log('email is "%s"',email);
	var rt = new requestTracker('node','Saeg4ahG');
	rt.login(function () {
		console.log('done');
		rt.createTicket({id:'ticket/new',Queue:queue,Requestor:email,Text:body},cb);
	});
}
module.exports.postTicket = postTicket;
