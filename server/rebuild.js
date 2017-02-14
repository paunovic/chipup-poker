#!/usr/bin/env node

var fs = require('fs');
var p = require("node-protobuf");

/*var data = fs.readFileSync('client/src/uServerCodes.pas','utf8');
var lines = data.split('\n');
var out = fs.openSync("server/codes.js","w");
fs.writeSync(out,'codes = {};\nmodule.exports = codes;\n');
for (var i=0; i<lines.length; i++) {
	var line = lines[i].trim();
	var res = /([A-Z_]+) += ([0-9]+);/.exec(line);
	if (!res) {
		console.log(JSON.stringify(line));
	} else {
		var name = res[1];
		var id = parseInt(res[2]);
		fs.writeSync(out,'codes.'+name+'='+id+';\n');
	}
}*/


var pb = new p(fs.readFileSync("server/descriptor.desc"));
var messages = fs.readFileSync("server/message.desc");
var data = pb.Parse(messages,"google.protobuf.FileDescriptorSet");
for (var i=0; i<data.file.length; i++) {
	var file = data.file[i];
	for (var j=0; j<file.enum_type.length; j++) {
		var reverse = [];
		var enum_type = file.enum_type[j];
		var out = fs.openSync("server/"+enum_type.name+".js","w");
		fs.writeSync(out,'codes = {};\nmodule.exports = codes;\n');
		for (var x=0; x < enum_type.value.length; x++) {
			var v = enum_type.value[x];
			fs.writeSync(out,'codes.'+enum_type.value[x].name+'='+enum_type.value[x].number+';\n');
			reverse[enum_type.value[x].number] = enum_type.value[x].name;
		}
		fs.writeSync(out,'codes.reverse = '+JSON.stringify(reverse)+';');
	}
}
