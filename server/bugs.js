var ObjectID = require('mongodb').ObjectID;
if (require.main === module) {
	var express = require('express');
	var MongoClient = require('mongodb').MongoClient;
	MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
		if (err) {
			console.log(err);
			process.exit(1);
		}
		var app = new express();
		var bugs = db.collection('bugs');
		app.configure(function () {});
		setup(app,bugs,db.collection('users'));
		app.listen(3001);
	});
}
function setup(app,bugs,users) {
	app.set('view engine','jade');
	app.get('/bugs',function (req,res) {
		bugs.find({}).toArray(function (err,data) {
			res.render('bugs',{bugs:data});
		});
	});
	app.get('/users',function (req,res) {
		users.find({}).toArray(function (err,data) {
			res.render('users',{users:data});
		});
	});
	app.get('/bug',function (req,res) {
		bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
			res.render('bug',{bug:row});
		});
	});
	app.get('/screenshot',function (req,res) {
		bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
			res.set({"Content-Disposition":'filename="'+row._id+'.png"',
				'Content-Type':'image/png'});
			res.send(row.ScreenShot.buffer);
		});
	});
}
module.exports.setup = setup;
