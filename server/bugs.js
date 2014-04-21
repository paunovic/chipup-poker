var ObjectID = require('mongodb').ObjectID;
var fs = require('fs');
var assert = require('assert');
var async = require('async');
var express = require('express');

var deck = require('./deck');


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
	app.use('/secure/',express.basicAuth(function mongoAuth(username,password,callback) {
		console.log('checking auth %s/%s',username,password);
		db.collection('admin').findOne({username:username},function (err,adminRow) {
			console.log('adminRow:%j',adminRow);
			if (adminRow) {
				// FIXME, add salt
				if (adminRow.password == password) {
					callback(null,true);
					return;
				}
			}
			callback(null,false);
		});
	}));
	var PokerProfile = db.collection('PokerProfile');
	app.set('view engine','jade');
	app.get('/secure/bugs',function (req,res) {
		var start = Date.now();
		bugs.find({}).toArray(function (err,data) {
			res.render('bugs',{bugs:data,start:start});
		});
	});
	app.get('/secure/serverBugs',function (req,res) {
		var start = Date.now();
		if (req.query.delete) {
			db.collection('serverErrors').remove({_id:new ObjectID(req.query.delete)},function () {});
		}
		db.collection('serverErrors').find().sort({_id:-1}).toArray(function (err,data) {
			res.render('serverErrors',{rows:data,start:start});
		});
	});
	app.get('/secure/users',function (req,res) {
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
	app.get('/secure/',function (req,res) {
		res.render('secure_index');
	});
	app.get('/secure/clubs',function (req,res) {
		var start = Date.now();
		db.collection('clubs').find({}).toArray(function (err,data) {
			res.render('clubs',{clubs:data,start:start});
		});
	});
	app.get('/secure/club',function (req,res) {
		var start = Date.now();
		db.collection('clubs').findOne({_id:new ObjectID(req.query.id)},function (err,club) {
			var userids = [ club.owner ];
			if (club.members) {
				for (var x=0; x<club.members.length; x++) {
					userids.push(club.members[x]);
				}
			}
			db.collection('games').find({clubid:new ObjectID(req.query.id)}).toArray(function (err,games) {
				users.find({_id:{$in:userids}}).toArray(function (err,users) {
					var usermap = {};
					for (var x=0; x<users.length; x++) {
						usermap[users[x]._id] = users[x];
					}
					res.render('club',{club:club,games:games,start:start,users:usermap});
				});
			});
		});
	});
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
	app.get('/secure/hand',function (req,res) {
		var start = Date.now();
		db.collection('handHistory').findOne({_id:new ObjectID(req.query.id)},function (err,hand) {
			res.render('hand',{hand:hand,start:start});
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
