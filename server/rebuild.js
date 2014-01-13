var fs = require('fs');
var data = fs.readFileSync('/home/clever/Dropbox/poker/uServerCodes.pas','utf8');
var lines = data.split('\r\n');
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
}
