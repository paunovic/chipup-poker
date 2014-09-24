var prizes = [ ];

function refreshTable() {
	console.log('prizes',prizes);
	var tbl = document.getElementById('prizes');
	console.log(tbl);
	for (var x=0; x<prizes.length; x++) {
		var row = document.getElementById('prize_'+x);
		if (!row) {
			var row = tbl.insertRow(x);
			row.id = 'prize_'+x;
			console.log('made row ',x);
			var cell = row.insertCell(-1);
			cell.textContent = x+1;
			cell.className = 'rank';
			cell = row.insertCell(-1);
			inp = document.createElement('input');
			cell.appendChild(inp);
			inp.addEventListener('blur',updatePrize.bind(this,inp));
			inp.addEventListener('keyup',updatePrize.bind(this,inp));
			inp.value = prizes[x];
			var inp2 = document.createElement('input');
			inp2.type = 'button';
			inp2.value = 'delete';
			inp2.addEventListener('click',removePrize.bind(this,inp));
			cell.appendChild(inp);
		}
		var del = document.querySelector('#prize_'+x+' .delete');
		if (!del) {
			console.log('added delete to row ',x);
			del = document.createElement('input');
			del.type = 'button';
			del.value = 'delete';
			del.addEventListener('click',removePrize.bind(this,row));
			del.className = 'delete';
			document.querySelector('#prize_'+x+' .name').parentNode.appendChild(del);
		}
	}
	if (prizes[x-1].length == 0) {
	} else {
		var inp = document.getElementById('prize_'+x);
		if (!inp) {
			var row = tbl.insertRow(-1);
			row.id = 'prize_'+x;
			console.log('made row ',x);
			var cell = row.insertCell(-1);
			cell.textContent = x+1;
			cell.className = 'rank';
			cell = row.insertCell(-1);
			var inp = document.createElement('input');
			cell.appendChild(inp);
			inp.addEventListener('blur',updatePrize.bind(this,row));
			inp.addEventListener('keyup',updatePrize.bind(this,row));
			inp.className = 'name';
			inp.tabIndex = x;
		}
	}
	document.getElementById('raw_prizes').value = JSON.stringify(prizes);

}
function updatePrize(row) {
	console.log('updating',row);
	var res = /prize_([0-9]+)/.exec(row.id);
	var index = parseInt(res[1]);
	var name = document.querySelector('#prize_'+index+' .name').value;
	prizes[index] = name;
	if (name.length > 0) refreshTable();
}
function removePrize(row) {
	var res = /prize_([0-9]+)/.exec(row.id);
	var index = parseInt(res[1]);
	console.log('deleting prize',index,row);
	prizes.splice(index,1);
	var row = document.getElementById('prize_'+index);
	row.parentNode.removeChild(row);
	for (var x=index+1; x<(prizes.length+2); x++) {
		var row = document.getElementById('prize_'+x);
		row.id = 'prize_'+(x-1);
		row.querySelector('.rank').textContent = x;
		row.querySelector('.name').tabIndex = x-1;
		console.log(row);
	}
	document.getElementById('raw_prizes').value = JSON.stringify(prizes);
}
