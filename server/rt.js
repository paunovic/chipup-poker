var http = require('http');
var rest = require('rest');

function requestTracker(user,pass) {
	this.user = user;
	this.pass = pass;
}
requestTracker.prototype.rest = function test(url,args,cb) {
	rest({path:'http://rt.chipuppoker.com:8080/REST/1.0/'+url,headers:{Cookie:this.auth,Referer:'http://rt.chipuppoker.com:8080/REST/1.0/'},entity:args}).then(function(response) {
		console.log('response: ', response.entity);
		if (cb) cb();
	});
	return;
}
requestTracker.prototype.login = function login(cb) {
	var req = http.request({hostname:'rt.chipuppoker.com',port:8080,method:'POST',
		headers:{
		'Content-Type': 'application/x-www-form-urlencoded'
		}
	},function (req) {
		req.on('data',function (data) {
			//console.log('data',data);
		});
		req.on('end',function () {
			this.auth = req.headers['set-cookie'][0].split(';')[0];
			console.log('done',this.auth);
			cb();
		}.bind(this));
	}.bind(this));
	req.write("user="+this.user+"&pass="+this.pass);
	req.end();
	req.on('error',function (err) {
		console.log('error',err);
	});
}
requestTracker.prototype.createTicket = function (obj,cb) {
	var out = [];
	for (var key in obj) {
		out.push(key+': '+(obj[key].replace('\n','\n ')));
	}
	out = out.join('\n');
	var data = 'content='+escape(out);
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
