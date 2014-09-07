function displayLog(log,elem) {
	var node = elem.parentNode;
	console.log(log,node);
	var tbl = document.createElement('table');
	tbl.border = 1;
	var header = document.createElement('tr');
	header.insertCell(-1).textContent = 'row#';
	header.insertCell(-1).textContent = 'total';
	header.insertCell(-1).textContent = 'spread';
	header.insertCell(-1).textContent = 'tables';
	tbl.appendChild(header);
	node.appendChild(tbl);
	function showTableCounts() {
		for (var y=0; y<record.counts.counts.length; y++) {
			var cell = row.insertCell(-1);
			cell.textContent = 'T'+y+' count:'+record.counts.counts[y].count;
			if (y == record.thisTable) cell.style.background = 'red';
		}
	}
	for (var x=0; x<log.records.length; x++) {
		var record = log.records[x];
		console.log(record);
		if (record.type == 'counts') {
			var row = document.createElement('tr');
			row.insertCell(-1).textContent = x;
			row.insertCell(-1).textContent = record.counts.total;
			row.insertCell(-1).textContent = record.counts.min+'-'+record.counts.max
			row.insertCell(-1).textContent = record.counts.active+'/'+ Math.ceil(record.counts.total / 6);
			showTableCounts(row,record);
			tbl.appendChild(row);
		} else if (record.type == 'xfer1') {
			var row = document.createElement('tr');
			row.insertCell(-1).textContent = x;
			row.insertCell(-1).textContent = record.msg;
			row.insertCell(-1).textContent = record.counts.min+'-'+record.counts.max
			row.insertCell(-1).textContent = record.counts.active+'/'+ Math.ceil(record.counts.total / 6);
			showTableCounts(row,record);
			tbl.appendChild(row);
		} else if (record.type == 'move') {
			var row = document.createElement('tr');
			row.insertCell(-1).textContent = x;
			row.insertCell(-1).textContent = 'move from T'+record.otable+'S'+record.oseat+'->T'+record.ttable+'S'+record.tseat;
			tbl.appendChild(row);
		} else if (record.type == 'bust') {
			var row = document.createElement('tr');
			row.insertCell(-1).textContent = x;
			row.insertCell(-1).textContent = 'T'+record.table+'S'+record.seat+' busted';
			tbl.appendChild(row);
		} else {
			var row = document.createElement('tr');
			row.insertCell(-1).textContent = x;
			row.colspan=4;
			var pre = document.createElement('pre');
			pre.textContent = JSON.stringify(record);
			row.insertCell(-1).appendChild(pre);
			tbl.appendChild(row);
		}
	}
}
function downloadLog(id,elem) {
	console.log(id);
	var xhr = new XMLHttpRequest();
	xhr.open('GET','/secure/tournament_log?id='+id,true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState == 4) {
			console.log(xhr.responseText);
			displayLog(JSON.parse(xhr.responseText),elem);
		}
	}
	xhr.send();
}
