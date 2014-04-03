var ObjectID = require('mongodb').ObjectID;
var fs = require('fs');
var assert = require('assert');

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
	var PokerProfile = db.collection('PokerProfile');
	app.set('view engine','jade');
	app.get('/bugs',function (req,res) {
		var start = Date.now();
		bugs.find({}).toArray(function (err,data) {
			res.render('bugs',{bugs:data,start:start});
		});
	});
	app.get('/serverBugs',function (req,res) {
		var start = Date.now();
		if (req.query.delete) {
			db.collection('serverErrors').remove({_id:new ObjectID(req.query.delete)},function () {});
		}
		db.collection('serverErrors').find().sort({_id:-1}).toArray(function (err,data) {
			res.render('serverErrors',{rows:data,start:start});
		});
	});
	app.get('/users',function (req,res) {
		var start = Date.now();
		users.find({}).toArray(function (err,data) {
			var sum = 0;
			for (var x=0; x<data.length; x++) {
				if (data[x].chips) sum += data[x].chips;
			}
			res.render('users',{users:data,start:start,sum:sum});
		});
	});
	app.get('/bug',function (req,res) {
		var start = Date.now();
		bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
			res.render('bug',{bug:row,start:start});
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
		var start = Date.now();
		db.collection('clubs').findOne({_id:new ObjectID(req.query.id)},function (err,club) {
			db.collection('games').find({clubid:new ObjectID(req.query.id)}).toArray(function (err,games) {
				res.render('club',{club:club,games:games,start:start});
			});
		});
	});
	app.get('/hand',function (req,res) {
		var start = Date.now();
		db.collection('handHistory').findOne({_id:new ObjectID(req.query.id)},function (err,hand) {
			res.render('hand',{hand:hand,start:start});
		});
	});
	app.get('/performance',function (req,res) {
		var start = Date.now();
		db.collection('system.profile').find({}).limit(50).sort({ts:-1}).toArray(function (err,rows) {
			res.render('profile',{rows:rows,start:start});
		});
	});
	app.get('/profile',function (req,res) {
		var start = Date.now();
		PokerProfile.aggregate({$group:{_id:'$tag', avg:{$avg:'$time'}, hits:{$sum:1} }}, function (err,rows) {
			PokerProfile.find({time:{$gt:2000}}).toArray(function (err,list) {
				res.render('profile2',{rows:rows,start:start,rawlist:list});
			});
		});
	});
}
module.exports.setup = setup;
