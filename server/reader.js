module.exports.reader = reader;
function reader(socket,handleLine) {
	this.buffer = '';
	this.activeGroup = -1;
	socket.setEncoding('utf8');
	socket.on('data',function(chunk) {
		this.buffer += chunk;
		var lines = this.buffer.split('\n');
		if (lines.length > 1) {
			for (var x=0; x<(lines.length-1); x++) {
				handleLine(lines[x].trim());
			}
			//console.log('remainder',lines,lines.length,lines[lines.length-1]);
			this.buffer = lines[lines.length-1];
		}
	}.bind(this));
}
