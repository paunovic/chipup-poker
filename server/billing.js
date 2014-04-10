#!/usr/bin/node
var MongoClient = require('mongodb').MongoClient;
var fs = require('fs');

var columns = [];
var header;

MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	fs.readFile(process.argv[2],'ascii',function (err,data) {
		var lines = data.split('\n');
		lines.shift();
		lines.pop();
		lines.pop();
		lines.pop();
		header = lines.shift().split(',');
		var input = [];
		header.forEach(function (name) {
			columns.push('`'+name+'`');
			input.push('?');
		});
		columns.push('year');
		columns.push('month');
		input.push('?');input.push('?');
		console.log(input.length);
		columns = columns.join(',');
		input = input.join(',');
		var res = /aws-cost-allocation-([0-9]{4})-([0-9]{2}).csv/.exec(process.argv[2]);
		var year = parseInt(res[1]);
		var month = parseInt(res[2]);
		console.log(year,month);
		db.collection('billing').remove({year:year,month:month},function () {
			var alloutput = [];
			lines.forEach(function (line,index) {
				var fields = parseRow(line);
				fields.year = year;
				fields.month = month;
				alloutput.push(fields);
			});
			db.collection('billing').insert(alloutput,function (err,row) {
				if (err) throw err;
				//console.log(row);
				db.close();
			});
		});
	});
});
function parseRow(line) { // ugly, but only way i can see
	var fields = {};
	var inField = false;
	var field = '';
	var index = 0;
	function add(x) {
		var num = parseFloat(x);
		var col = header[index];
		//console.log('x:"%s" index:%d name:%s %s',x,index,header[index],num);
		if ((['CostBeforeTax','Credits','TaxAmount','TotalCost','UsageQuantity','RateId','PayerAccountId','LinkedAccountId'].indexOf(col) != -1) && (num)) {
			fields[header[index]] = num;
		} else if (x == '') {}
		else fields[header[index]] = x;
		index++;
	}
	for (var i = 0; i < line.length; i++) {
		var x = line[i];
		if (inField == false) {
			if (x == '"') {
				inField = true;
			} else if (x == ',') {
				add(field);
				field = '';
			}
		} else {
			if (x == '"') {
				inField = false;
			} else {
				field += x;
			}
		}
	}
	add(field);
	return fields;
}
