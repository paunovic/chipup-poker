var socket = io.connect("http://dev-server.chipuppoker.com:3000");
function buildRevision(hash) {
	console.log(hash);
	var xhr = new XMLHttpRequest();
	xhr.open('POST','/secure/buildbot',true);
	xhr.setRequestHeader("Content-Type","application/json");
	xhr.onreadystatechange = function () {
		if (xhr.readyState == 4) {
			console.log(xhr.responseText);
		}
	}
	var state = { revision: hash };
	xhr.send(JSON.stringify(state));
}
socket.on('new_installer',function (obj) {
	console.log(obj);
	if (obj.debug == 'debug') var tbl = document.getElementById('debug_installers');
	if (obj.debug == 'release') var tbl = document.getElementById('release_installers');
	var row = tbl.insertRow(-1);
	row.insertCell(-1).textContent = obj.ts;
	var link = document.createElement('a');
	link.textContent = 'installer';
	link.href = '/rawinstallers/'+obj.name
	row.insertCell(-1).appendChild(link);
	row.insertCell(-1).textContent = obj.version;
	row.insertCell(-1).textContent = obj.revision;
	row.insertCell(-1).textContent = Math.floor(obj.size/1024/1024)+'MB';
	var activate = document.createElement('input');
	activate.type = 'radio';
	activate.name = 'activate_'+obj.debug;
	activate.value = obj._id;
	row.insertCell(-1).appendChild(activate);
	var statusDelete = document.createElement('input');
	statusDelete.type = 'checkbox';
	statusDelete.name = 'delete_'+obj._id;
	row.insertCell(-1).appendChild(statusDelete);
});
socket.on('new_revision',function (obj) {
	console.log(obj);
	document.getElementById('lastMsg').textContent = obj.msg;
	document.getElementById('buildButton').onclick = 'buildRevision("'+obj.hash+'")';
});
