var config = {};
var month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

if (document.location.protocol == 'https:') {
	url = 'https://dev-server.chipuppoker.com';
	config.transports = ['xhr-polling'];
} else url = 'http://dev-server.chipuppoker.com:3000';
var socket = io.connect(url,config);
function buildRevision(hash) {
	console.log(hash);
	// FIXME, use socket.io
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
	row.insertCell(-1).textContent = formatDate(new Date(obj.ts));
	var link = document.createElement('a');
	link.textContent = obj.version;
	link.href = '/rawinstallers/'+obj.name
	row.insertCell(-1).appendChild(link);
	row.insertCell(-1).textContent = obj.revision;
	row.insertCell(-1).textContent = (obj.size/1024/1024).toFixed(2)+'MB';

	activate = document.createElement('input');
	activate.type = 'radio';
	activate.name = 'activate_dev_'+obj.debug;
	activate.value = obj._id;
	activate.className = 'activate';
	row.insertCell(-1).appendChild(activate);

	var activate = document.createElement('input');
	activate.type = 'radio';
	activate.name = 'activate_live_'+obj.debug;
	activate.value = obj._id;
	activate.className = 'activate';
	row.insertCell(-1).appendChild(activate);

	var statusDelete = document.createElement('input');
	statusDelete.type = 'checkbox';
	statusDelete.name = 'delete_'+obj._id;
	row.insertCell(-1).appendChild(statusDelete);

	if (obj.hashes) {
		option = document.createElement('input');
		option.type = 'radio';
		option.name = 'diff_source';
		option.onchange="changeSource('"+obj.hashes['chipuppoker:exe']+"')";
		row.insertCell(-1).appendChild(option);
		option = document.createElement('input');
		option.type = 'radio';
		option.name = 'diff_dest';
		option.onchange="changeSource('"+obj.hashes['chipuppoker:exe']+"')";
		row.insertCell(-1).appendChild(option);
	}
});
socket.on('new_revision',function (obj) {
	console.log(obj);
	document.getElementById('lastMsg').textContent = obj.msg;
	document.getElementById('buildButton').onclick = function () {
		buildRevision(obj.hash);
	}
});
socket.on('makeDiff',function (obj) {
	console.log('makeDIff',obj);
	var msg = 'making diff for '+obj.path;
	if (obj.size) {
		msg += ' it is '+obj.size+' bytes';
		if ( (obj.sourcehash == sourceHash) && (obj.desthash == destHash) ) {
			checkDiff();
		}
	}
});
function masscheck() {
	var list = document.querySelectorAll('.deleteCheckbox');
	console.log(list);
	for (var x=0; x<list.length; x++) list[x].checked = true;
	checkLatest();
}
function checkLatest() {
	var list = document.querySelectorAll('.installers tr:last-of-type .activate');
	for (var x=0; x<list.length; x++) {
		list[x].checked = true;
	}
}
var sourceHash,destHash;
function changeSource(hash) {
	console.log('source',hash);
	sourceHash = hash;
	checkDiff();
}
function changeDest(hash) {
	console.log('dest',hash);
	destHash = hash;
	checkDiff();
}
function checkDiff() {
	// FIXME, use socket.io once ssl is fixed
	var xhr = new XMLHttpRequest();
	xhr.open('POST','/secure/diffStats',true);
	xhr.setRequestHeader("Content-Type","application/json");
	xhr.onreadystatechange = function () {
		if (xhr.readyState == 4) {
			console.log(xhr.responseText);
			var res = JSON.parse(xhr.responseText);
			var stats = document.getElementById('diffStats');
			var make = document.getElementById('makeDiff');
			if (res) {
				if (stats) stats.textContent = 'diff size:'+res.size;
				make.style.display = 'none';
			} else {
				if (stats) stats.textContent = '';
				make.style.display = '';
			}
		}
	}
	var req = { source:sourceHash, dest:destHash };
	xhr.send(JSON.stringify(req));
}
function makeDiff2() {
	// FIXME, use socket.io once ssl is fixed
	if (!sourceHash || !destHash) {
		alert('you must select both a source and dest');
		return;
	}
	var xhr = new XMLHttpRequest();
	xhr.open('POST','/secure/makeDiff',true);
	xhr.setRequestHeader("Content-Type","application/json");
	xhr.onreadystatechange = function () {
		if (xhr.readyState == 4) {
			console.log(xhr.responseText);
		}
	}
	var req = { sourcehash:sourceHash, desthash:destHash, path:'chipuppoker.exe' };
	xhr.send(JSON.stringify(req));
}

function formatDate(input) {
	function pad(x) {
		if (x < 10) return "0"+x;
		return x;
	}
	var out = pad(input.getDate())+" "+month_names[input.getMonth()]+" "+input.getFullYear()+"&nbsp;&nbsp;&nbsp;"+pad(input.getHours())+":"+pad(input.getMinutes());
	return out;
}
