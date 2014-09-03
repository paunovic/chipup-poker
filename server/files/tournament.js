function selectLog(idx,elem) {
	var node = elem.parentNode;
	var log = logs[idx];
	console.log(log,node);
	var tbl = document.createElement('table');
	tbl.border = 1;
	var header = document.createElement('tr');
	header.insertCell(-1).textContent = 'total';
	header.insertCell(-1).textContent = 'spread';
	header.insertCell(-1).textContent = 'this table';
	header.insertCell(-1).textContent = 'active';
	header.insertCell(-1).textContent = 'min tables';
	tbl.appendChild(header);
	node.appendChild(tbl);
	for (var x=0; x<log.records.length; x++) {
		var record = log.records[x];
		console.log(record);
		if (record.type == 'counts') {
			var row = document.createElement('tr');
			row.insertCell(-1).textContent = record.counts.total;
			row.insertCell(-1).textContent = record.counts.min+'-'+record.counts.max
			row.insertCell(-1).textContent = record.counts.players_at_this_table;
			row.insertCell(-1).textContent = record.counts.active;
			row.insertCell(-1).textContent = Math.ceil(record.counts.total / 6);
			tbl.appendChild(row);
		} else {
			var row = document.createElement('tr');
			row.colspan=4;
			var pre = document.createElement('pre');
			pre.textContent = JSON.stringify(record);
			row.insertCell(-1).appendChild(pre);
			tbl.appendChild(row);
		}
	}
}
