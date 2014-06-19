"use strict";

var http = require('http');
var fs = require('fs');
var assert = require('assert');
var child_process = require('child_process');

var config = require('./config');
var ReadWriteLock = require('./lock'); // FIXME, send them a PR?, fork it?, it came from the rwlock npm package
var profiler = require('./profiler');
var models = require('./db').models;

module.exports.makeDiff = makeDiff;

var bsdiffLock = new ReadWriteLock();

function makeDiff(sourcehash,desthash,path) {
	function pushDiff(doc) {
		var body = new Buffer(JSON.stringify(doc));
		var req = http.request({host:'chipuppoker.com',method:'POST',path:'/sync/newDiff',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
		req.on('data',function (chunk) {
			console.log(chunk);
		});
		req.on('error',function (err) {
			console.log('http error sending diff:',err);
		});
		req.write(body);
		req.end();
	}
	if (!config.diffserver) {
		console.log('need to ask diff server for %s',path);
		var body = new Buffer(JSON.stringify({sourcehash:sourcehash,desthash:desthash,path:path}));
		var req = http.request({host:'dev-server.chipuppoker.com',method:'POST',path:'/sync/makeDiff',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
		req.on('data',function (chunk) {
			console.log('chunk');
		});
		req.on('error',function (err) {
			console.log('http error asking for diff:',err);
		});
		req.write(body);
		req.end();
		return;
	}
	fs.stat("unpacked/objects/"+sourcehash,function (err,localCopy) {
		console.log('localCopy:%j',localCopy);
		if (localCopy) {
			bsdiffLock.writeLock(function bsdiffLocked(release) {
				models.Diff.findOne({sourcehash:sourcehash,desthash:desthash},function (err,diffRow) {
					assert.ifError(err);
					if (diffRow) {
						pushDiff(diffRow);
						return release();
					}
					console.log('making diff for %s',path);
					var outfile = 'diffs/'+sourcehash+'-'+desthash+'.diff';
					bsdiff("unpacked/objects/"+sourcehash,"unpacked/objects/"+desthash,outfile,function (err,stats) {
						assert.ifError(err);
						var doc = { sourcehash:sourcehash, desthash:desthash, size:stats.size, url:'http://'+config.staticserver+'/'+outfile };
						var obj = new models.Diff(doc);
						obj.save(doc,function () {
							pushDiff(doc);
							release();
						});
					});
				});
			});
		}
	});
}

function bsdiff(oldfile,newfile,diff,cb) {
	var token = profiler.start('bsdiff');
	console.log('diffing %s and %s into %s',oldfile,newfile,diff);
	var differ = child_process.spawn('bsdiff',[oldfile,newfile,diff],{stdio:'inherit'});
	differ.on('close',function () {
		fs.stat(diff,function (err,stats) {
			token.stop();
			cb(err,stats);
		});
	});
}
