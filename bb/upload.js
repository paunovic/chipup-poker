var fs = require('fs');
var child = require('child_process');
var http = require('http');

var data = fs.readFileSync('../client/src/modules/settings/Poker.HardcodedSettings.pas');
var res = /VERSION *: *'([0-9.a-z]+)';/.exec(data);
console.log('version='+res[1]);

child.exec('git rev-parse HEAD',function (err,stdout,stderr) {
	console.log('revision='+stdout.trim());
	fs.writeFileSync("version.inc",'revision='+stdout.trim());
	finish(stdout.trim());
});

function finish(version) {
	doUpload(version,'internal.chipuppoker.com');
	doUpload(version,'chipuppoker.com');
}
function doUpload(version,host) {
	var key = 'abcd';
	var header = '--'+key+'\r\n'+
		'Content-Type: application/octed-stream\r\n'+
		'Content-Disposition: form-data; name="installer"; filename="install_chipuppoker.exe"\r\n'+
		'Content-Transfer-Encoding: binary\r\n\r\n';
	var middle = '\r\n--'+key+'\r\n'+
		'Content-Type: application/octed-stream\r\n'+
		'Content-Disposition: form-data; name="client"; filename="client.exe"\r\n'+
		'Content-Transfer-Encoding: binary\r\n\r\n';
	var footer = '\r\n--'+key+'--';

	var textsize = header.length + middle.length + footer.length;
	var filesize1 = fs.statSync('../client/installer/install_chipuppoker.exe').size;
	var filesize2 = fs.statSync('../client/src/client.exe').size;

	var request = http.request({host:host,method:'POST',path:'/newVersion?version='+res[1]+'&revision='+version+
		'&debug='+process.argv[2],
		headers:{'Content-Length':textsize+filesize1+filesize2}
	},function (res) {
		console.log('done?');
		res.on('data',function (chunk) {
			console.log('body:'+chunk);
		});
	});
	request.on('error',function (err) {
		console.log('unable to upload to %s due to %j',host,err);
	});
	console.log('doing post');
	request.setHeader('Content-Type','multipart/form-data; boundary="'+key+'"');
	request.write(header);
	console.log('making stream');
	fs.createReadStream('../client/installer/install_chipuppoker.exe',{bufferSize: 4*1024})
		.on('end',function () {
			request.write(middle);
			fs.createReadStream('../client/src/client.exe',{bufferSize: 4*1024})
				.on('end',function () {
					console.log('ending');
					request.end(footer);
				})
				.pipe(request,{end:false});
		})
		.pipe(request,{end:false});
}
