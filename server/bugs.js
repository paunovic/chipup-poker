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
		setup(app,bugs,db.collection('users'),db);
		app.listen(3001);
		console.log('up');
	});
}
function setup(app,bugs,users,db) {
	app.set('view engine','jade');
	app.get('/bugs',function (req,res) {
		var start = Date.now();
		bugs.find({}).toArray(function (err,data) {
			res.render('bugs',{bugs:data,start:start});
		});
	});
	app.get('/users',function (req,res) {
		var start = Date.now();
		users.find({}).toArray(function (err,data) {
			res.render('users',{users:data,start:start});
		});
	});
	app.get('/user',function (req,res) {
		users.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
			db.collection('clubs').find({members:new ObjectID(req.query.id)}).toArray(function (err,clubs) {
				res.render('user',{user:row,clubs:clubs});
			});
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
	app.get('/clubs',function (req,res) {
		var start = Date.now();
		db.collection('clubs').find({}).toArray(function (err,data) {
			res.render('clubs',{clubs:data,start:start});
		});
	});
	app.get('/club',function (req,res) {
		db.collection('clubs').findOne({_id:new ObjectID(req.query.id)},function (err,club) {
			db.collection('games').find({clubid:new ObjectID(req.query.id)}).toArray(function (err,games) {
				res.render('club',{club:club,games:games});
			});
		});
	});
}
module.exports.setup = setup;
