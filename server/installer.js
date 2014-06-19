var fs = require('fs');
var async = require('async');
var assert = require('assert');
var child_process = require('child_process');
var crypto = require('crypto');
var http = require('http');

var config = require('./config');
var models = require('./db').models;

module.exports.unpackInstaller = unpackInstaller;
function unpackInstaller(io,record,objectSizes,cb1) {
	function updateLive(doc,sizes,cb) {
		var body = new Buffer(JSON.stringify({installer:doc,sizes:sizes}));
		var req = http.request({host:'chipuppoker.com',method:'POST',path:'/sync/newVersion',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
		req.on('data',function (chunk) {
			console.log(chunk);
		});
		req.on('error',function (err) {
			console.log('http error sending new version:',err);
		});
		req.write(body);
		req.end();
		cb();
	}
	function hashFiles(files) {
		var hashes = {};
		var sizes = [];
		async.each(files,function hashFile(filename,cb2) {
			var hasher = crypto.createHash('sha256');
			var client = fs.createReadStream('unpacked/'+record._id+'/app/'+filename);
			var size = 0;
			client.on('data',function (data) {
				hasher.update(data);
				size += data.length;
			});
			client.on('end',function () {
				var hash = hasher.digest('hex');
				console.log('hash of %s is %s',filename,hash);
				var key = filename.replace('.','_');
				sizes.push({_id:hash, size:size});
				hashes[key] = hash;
				copyFile('unpacked/'+record._id+'/app/'+filename,'unpacked/objects/'+hash,function () {
					fs.unlink('unpacked/'+record._id+'/app/'+filename,function () {
						cb2();
					});
				});
			});
		},function () {
			record.hashes = hashes;
			record.save(function (err,newdoc) {
				assert.ifError(err);
				if (err) console.log(err);
				console.log('inserted %j',newdoc);
				fs.rmdir('unpacked/'+record._id+'/app/',function () {
					fs.rmdir('unpacked/'+record._id,function () {
						installers.findOne(key,function (err,doc) {
							async.each(sizes,function (row,cb) {
								objectSizes.save(row,cb);
							},function () {
								updateLive(doc,sizes,function () {
									cb1(true);
								});
							});
						});
					});
				});
			});
		});
	}
	function recurse_dir(path,prefix,cb4) {
		var items = [];
		fs.readdir(prefix+path,function (err,files) {
			console.log('checked path %s %s',prefix,path);
			assert.ifError(err);
			async.each(files,function checkItem(filename,cb3) {
				fs.stat(prefix+path+filename,function (err,stats) {
					assert.ifError(err);
					console.log('stats:%j',stats);
					if (stats.isDirectory()) {
						recurse_dir(filename+'/',prefix,function (err,items2) {
							console.log('2nd level %j',items2);
							assert.ifError(err);
							items = items.concat(items2);
							cb3();
						});
					} else if (stats.isFile()) {
						items.push(path+filename);
						cb3();
					}
				});
			},function () {
				cb4(null,items);
			});
		});
	}
	var unpacker = child_process.spawn('innoextract',['-l','-d','unpacked/'+record._id+'/','-e','installers/'+record.name],{stdio:'inherit'});
	unpacker.on('close',function (code) {
		if (code != 0) {
			cb1(false);
			return;
		}
		assert.equal(code,0);
		recurse_dir('','unpacked/'+record._id+'/app/',function (err,files) {
			assert.ifError(err);
			console.log('all files:%j',files);
			hashFiles(files);
		});
	});
}
function copyFile(source,dest,cb) {
	fs.stat(dest,function (err,stat) {
		if (stat) return cb();

		var input = fs.createReadStream(source);
		var output = fs.createWriteStream(dest);
		input.pipe(output);
		input.on('end',cb);
	});
}
