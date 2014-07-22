var socket = io.connect("http://control.chipuppoker.com:8080");
var filter = /XXXXXXXXXXXX/;
var bots = {};

function start() { socket.emit('start'); }
function stop() { socket.emit('stop'); }
function restart() { socket.emit('restart'); }
socket.on('message',function (obj) {
	var autoscroll = document.getElementById('autoScroll').checked;
	if (document.getElementById('debug').children.length > 500) document.getElementById('debug').removeChild(document.getElementById('debug').children[0]);
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
socket.on('botStarted',function (obj) {
	if (bots[obj.name]) {
		var bot = bots[obj.name];
		bot.node.parentNode.removeChild(bot.node);
	}
	var bot = {};
	bots[obj.name] = bot;
	bot.node = document.createElement('div');
	document.getElementById('bots').appendChild(bot.node);
	var button = document.createElement('input');
	button.type = 'button';
	button.addEventListener('click',function () {
		socket.emit('stopBot',{name:obj.name, target:'live'} );
	});
	button.value = 'stop bot '+obj.name;
	bot.node.appendChild(button);
});
socket.on('botStopped',function (name) {
	if (bots[name]) {
		var bot = bots[name];
		bot.node.parentNode.removeChild(bot.node);
		delete bots[name];
	}
});
function updatefilter() {
	var text = document.getElementById('blacklist').value;
	filter = new RegExp(text);
}
function startBot() {
	var setname = document.getElementById('setname').value;
	var mode = document.getElementById('mode').value;
	socket.emit('startBot',{name:setname,mode:mode,target:'live'});
}
