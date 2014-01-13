var im_hub;
var buffer = [];
Error.stackTraceLimit = 20;
var retry = 20;
function startImHub() {
	im_hub = require('child_process').spawn('node',['server.js']);
	im_hub.stdout.setEncoding('utf8');
	im_hub.stdout.on('data',readStdOut);
	im_hub.stderr.setEncoding('utf8');
	im_hub.stderr.on('data',readStdErr);
	process.stdin.pipe(im_hub.stdin);
	//process.stdin.resume();
	im_hub.on('exit',restartImHub);
}
function readStdOut(data) {
	buffer.push(data);
	while (buffer.length > 200) buffer.shift();
	process.stdout.write(data);
}
function readStdErr(data) {
	buffer.push(data);
	while (buffer.length > 200) buffer.shift();
	process.stdout.write(data);
}
function restartImHub(code) {
	//var db = require('./db').makeIt();
	//db.verbose = true;
	//var fulllog = buffer.join('');
	//console.log(fulllog.length,'restartImHub',code);
	console.log('restarting...');
	//db.doQuery('INSERT INTO im_hub_crashes (buffer,code) VALUES (?,?)',[fulllog,code]);
	//db.db.end();
	buffer = [];
	setTimeout(startImHub,5000);
}
startImHub();
