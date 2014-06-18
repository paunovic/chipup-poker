exports.fuzzerLoop = function (test) {
	var originalMsg = Core.pb.Serialize({debug:true},'Poker.HelloParams');
	function testByte(byteOffset,value,cb) {
		var copy = new Buffer(originalMsg);
		copy[byteOffset] = value;
		var root = new Core(function (method,args) {
			//root.debugHandle(method,args);
			if (method == root.codes.srHello) {
				test.ok(true);
				root.socket.destroy();
				cb();
			}
		});
		root.reply(root.codes.scHello,copy,'raw');
		root.socket.on('end',function () {
			test.ok(true);
			cb();
		});
	}
	var jobs = [];
	for (var x=0; x<originalMsg.length; x++) {
		for (var y=0; y<256; y++) {
			jobs.push([x,y]);
		}
	}
	test.expect(jobs.length);
	async.eachLimit(jobs,10,function (job,cb) {
		testByte(job[0],job[1],cb);
	},function () {
		test.done();
	});
}
exports.ping_timeout1 = function (test) {
	test.expect(2);
	var root = new Core(function (method,args) {
		//root.debugHandle(method,args);
		if (method == root.codes.srHello) test.ok(true,'got scHello');
	});
	//root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
	var timer = setTimeout(fail,110000);
	function fail() {
		console.log('FAIL!');
		root.socket.destroy();
		console.log('calling done');
		test.ok(false,"ping timeout didnt work");
		test.done();
	}
	root.socket.on('end',function() {
		clearTimeout(timer);
		console.log('socket closed');
		root.socket.destroy();
		test.ok(true,'ping timeout worked');
		test.done();
	});
}
exports.testRegisterLong = function (test) {
	var name = "unittest"+Math.random();
	var root = new Core(function (method,args) {
		var obj = root.debugHandle(method,args);
		if (method == root.codes.srHello) {
			root.reply(root.codes.scRegister,{email:name+'@server.com',password:'password',displayName:name},'Poker.RegisterParams');
		} else if (method == root.codes.srRegisterReply) {
			test.equal(obj.status,'regInvalidName');
			root.socket.destroy();
			test.done();
		}
	});
	root.socket.on('end',function () {
		test.ok(false);
		test.done();
	});
	root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
}
var username = this.name = "unittest"+Math.random();
username = username.substr(0,20);
exports.testRegisterAndLogin = {
	testRegister: function (test) {
		var name = username;
		var root = new Core(function (method,args) {
			var obj = root.debugHandle(method,args);
			if (method == root.codes.srHello) {
				root.reply(root.codes.scRegister,{email:name+'@server.com',password:'password',displayName:name},'Poker.RegisterParams');
			} else if (method == root.codes.srRegisterReply) {
				test.equal(obj.status,'regSuccess');
				root.socket.destroy();
				test.done();
			}
		});
		root.socket.on('end',function () {
			test.ok(false);
			test.done();
		});
		root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
	},
	testLogin: function (test) {
		var name = username;
		var root = new Core(function (method,args) {
			var obj = root.debugHandle(method,args);
			if (method == root.codes.srHello) {
				root.reply(root.codes.scLogin,{username:name+'@server.com',password:'password'},'Poker.LoginParams');
			} else if (method == root.codes.srLoginReply) {
				test.equal(obj.login_status,'lrSuccess');
				root.socket.destroy();
				test.done();
			}
		});
		root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
	}
}
