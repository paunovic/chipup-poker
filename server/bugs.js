var ObjectID = require('mongodb').ObjectID;
var fs = require('fs');
var assert = require('assert');
var async = require('async');
var express = require('express');
var crypto = require('crypto');

if (require.main === module) {
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
	app.get('/secure/reports',function (req,res) {
		if (req.query.close) {
			db.collection('contacts').update({_id:new ObjectID(req.query.close)},{$set:{closed:true}},function (err) {
				console.log(err);
			});
		}
		db.collection('contacts').find({closed:false}).toArray(function (err,reports) {
			var userids = [];
			for (var x=0; x<reports.length; x++) {
				userids.push(reports[x].userid);
			}
			users.find({_id:{$in:userids}}).toArray(function (err,users) {
				var usermap = {};
				for (var x=0; x<users.length; x++) {
					usermap[users[x]._id] = users[x];
				}
				res.render('reports',{reports:reports,users:usermap});
			});
		});
	});
	app.get('/secure/performance',function (req,res) {
		var start = Date.now();
		db.collection('system.profile').find({}).limit(50).sort({ts:-1}).toArray(function (err,rows) {
			res.render('profile',{rows:rows,start:start});
		});
	});
	app.get('/secure/profile',function (req,res) {
		var start = Date.now();
		PokerProfile.aggregate({$group:{_id:'$tag', avg:{$avg:'$time'}, hits:{$sum:1} }}, function (err,rows) {
			PokerProfile.find({time:{$gt:2000}}).toArray(function (err,list) {
				res.render('profile2',{rows:rows,start:start,rawlist:list});
			});
		});
	});
	app.get('/secure/disk',function (req,res) {
		var start = Date.now();
		db.stats(function (err,stats) {
			db.collectionNames(function (err,names) {
				var out = [];
				var input = [];
				for (var x=0; x<names.length; x++) {
					input.push(names[x].name);
				}
				input.sort();
				async.eachLimit(input,1,function (item,cb) {
					db.collection(item.split('.')[1]).stats(function (err,stats) {
						if (!stats) {
							console.log('name:%s stats:',item,stats);
							cb();
							return;
						}
						out.push(stats);
						cb();
					});
				},function done(err) {
					res.render('disk',{dbstats:stats,start:start,stats:out});
				});
			});
		});
	});
	app.get('/secure/billing',function (req,res) {
		var start = Date.now();
		db.collection('billing').find({TotalCost:{$gt:0}},{ProductCode:1,ProductName:1,UsageType:1,ItemDescription:1,CostBeforeTax:1,TotalCost:1,UsageQuantity:1,"user:Name":1,"user:service":1,year:1,month:1}).toArray(function (err,rows) {
			res.render('billing',{billing:rows,start:start});
		});
	});
}
module.exports.setup = setup;
