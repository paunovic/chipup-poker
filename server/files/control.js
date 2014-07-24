var socket = io.connect("http://control.chipuppoker.com:8080");
var filter = /XXXXXXXXXXXX/;
var bots = {};
var activeServer = 'dev';

function start() { socket.emit('start'); }
function stop() { socket.emit('stop'); }
function restart() { socket.emit('restart'); }
socket.on('message',function devMsg(obj) {
	if (activeServer == 'dev') processMessage(obj);
});
function processMessage(obj) {
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
}
socket.on('botStarted',function (obj) {
	var id = 'dev_bots';
	if (obj.target == 'live') id = 'live_bots';
	if (bots[obj.name+id]) {
		var bot = bots[obj.name+id];
		bot.node.parentNode.removeChild(bot.node);
	}
	var bot = {};
	bots[obj.name+id] = bot;
	bot.node = document.createElement('div');
	document.getElementById(id).appendChild(bot.node);
	var button = document.createElement('input');
	button.type = 'button';
	button.addEventListener('click',function () {
		socket.emit('stopBot',{name:obj.name, target:obj.target} );
	});
	button.value = 'stop bot '+obj.name;
	bot.node.appendChild(button);
});
socket.on('botStopped',function (obj) {
	var id = 'dev_bots';
	if (obj.target == 'live') id = 'live_bots';
	if (bots[obj.name+id]) {
		var bot = bots[obj.name+id];
		bot.node.parentNode.removeChild(bot.node);
		delete bots[obj.name+id];
	}
});
socket.on('live',function (obj) {
	if (activeServer == 'live') processMessage(obj);
});
function updatefilter() {
	var text = document.getElementById('blacklist').value;
	filter = new RegExp(text);
}
function startBot() {
	var setname = document.getElementById('setname').value;
	var mode = document.getElementById('mode').value;
	socket.emit('startBot',{name:setname,mode:mode,target:activeServer});
}
function changeServer(name) {
	socket.emit('changeServer',name);
	activeServer = name;
}
