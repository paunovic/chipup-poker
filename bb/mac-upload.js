var fs = require('fs');
var child = require('child_process');
var https = require('https');

var version = 'FIXME';
console.log('version='+version);

child.exec('git rev-parse HEAD',function (err,stdout,stderr) {
	console.log('revision='+stdout.trim());
	fs.writeFileSync("version.inc",'revision='+stdout.trim());
	finish(stdout.trim());
});

function finish(revision) {
	//doUpload(version,'master.chipuppoker.com');
	doUpload(revision,'dev-server.chipuppoker.com');
	//doUpload(version,'poker.angeldsis.com');
}
function doUpload(revision,host) {
	var key = 'abcd';
	var header = '--'+key+'\r\n'+
		'Content-Type: application/octed-stream\r\n'+
		'Content-Disposition: form-data; name="dmg"; filename="chipuppoker.dmg"\r\n'+
		'Content-Transfer-Encoding: binary\r\n\r\n';
	var middle = '\r\n--'+key+'\r\n'+
		'Content-Type: application/octed-stream\r\n'+
		'Content-Disposition: form-data; name="tar"; filename="chipuppoker.tar.bz2"\r\n'+
		'Content-Transfer-Encoding: binary\r\n\r\n';
	var footer = '\r\n--'+key+'--';

	var textsize = header.length + middle.length + footer.length;
	// ~/Qt/5.4/clang_64/bin/macdeployqt chipuppoker.app/ -dmg
	var filesize1 = fs.statSync('../../buildbot-build/client/chipuppoker.dmg').size;
	// tar -cvjf chipuppoker.tar.bz2 chipuppoker.app/
	var filesize2 = fs.statSync('../../buildbot-build/client/chipuppoker.tar.bz2').size;

	var request = https.request({hostname:host,method:'POST',path:'/addMac?version='+version+'&revision='+revision+
		'&buildnum='+process.argv[2],
		headers:{'Content-Length':textsize+filesize1+filesize2},
		ca:fs.readFileSync('sub.class1.server.ca.pem'),
		rejectUnauthorized:false
	},function (res) {
		console.log('%s reply',host);
		res.on('data',function (chunk) {
			console.log('%s body:%s',host,chunk);
		});
	});
	request.on('error',function (err) {
		console.log('unable to upload to %s due to',host,err);
	});
	console.log('doing post');
	request.setHeader('Content-Type','multipart/form-data; boundary="'+key+'"');
	request.write(header);
	console.log('making stream');
	fs.createReadStream('../../buildbot-build/client/chipuppoker.dmg',{bufferSize: 4*1024})
		.on('end',function () {
			request.write(middle);
			fs.createReadStream('../../buildbot-build/client/chipuppoker.tar.bz2',{bufferSize: 4*1024})
				.on('end',function () {
					console.log('%s ending',host);
					request.end(footer);
				})
				.pipe(request,{end:false});
		})
		.pipe(request,{end:false});
}
