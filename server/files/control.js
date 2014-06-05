var socket = io.connect("http://control.chipuppoker.com:8080");
var filter = /XXXXXXXXXXXX/;

function start() { socket.emit('start'); }
function stop() { socket.emit('stop'); }
function restart() { socket.emit('restart'); }
socket.on('message',function (obj) {
	var autoscroll = document.getElementById('autoScroll').checked;
	switch (obj.type) {
	case 'conn':
		var div = document.createElement('div');
		var p = document.createElement('p');
		p.textContent = JSON.stringify(obj);
		var ts = document.createElement('span');
		ts.className = 'ts';
		ts.textContent = obj.ts;
		div.appendChild(ts);

		var nick = document.createElement('span');
		nick.className = 'nick';
		nick.textContent = obj.nick;
		div.appendChild(nick);

		var connid = document.createElement('span');
		connid.className = 'connid';
		connid.textContent = obj.connid;
		div.appendChild(connid);

		for (var x=0; x<obj.objects.length; x++) {
			if (filter.exec(obj.objects[x])) return;
			var t = document.createElement('pre');
			t.className = 'msg';
			t.textContent = obj.objects[x];
			div.appendChild(t);
		}
		document.getElementById('debug').appendChild(div);
		if (autoscroll) div.scrollIntoView();
		break;
	case 'game':
		var div = document.createElement('div');
		div.className = 'typeGame';
		var p = document.createElement('p');
		p.textContent = JSON.stringify(obj);
		var ts = document.createElement('span');
		ts.className = 'ts';
		ts.textContent = obj.ts;
		div.appendChild(ts);

		var nick = document.createElement('span');
		nick.className = 'gameName';
		nick.textContent = obj.name;
		div.appendChild(nick);

		for (var x=0; x<obj.objects.length; x++) {
			if (filter.exec(obj.objects[x])) return;
			var t = document.createElement('pre');
			t.className = 'msg';
			t.textContent = obj.objects[x];
			div.appendChild(t);
		}
		document.getElementById('debug').appendChild(div);
		if (autoscroll) div.scrollIntoView();
		break;
	case 'global':
		var div = document.createElement('div');
		div.className = 'typeGlobal';
		var p = document.createElement('p');
		p.textContent = JSON.stringify(obj);
		var ts = document.createElement('span');
		ts.className = 'ts';
		ts.textContent = obj.ts;
		div.appendChild(ts);

		if (filter.exec(obj.msg)) return;
		var t = document.createElement('pre');
		t.className = 'msg';
		t.textContent = obj.msg;
		div.appendChild(t);
		
		document.getElementById('debug').appendChild(div);
		if (autoscroll) div.scrollIntoView();
		break;
	default:
		console.log(obj);
	}
});
function updatefilter() {
	var text = document.getElementById('blacklist').value;
	filter = new RegExp(text);
}
