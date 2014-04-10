var MongoClient = require('mongodb').MongoClient;
console.log(process.argv)
MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	var users = db.collection('users');
	for (var x=0; x<5; x++) {
		users.update({displayname:"set"+process.argv[2]+x},{$inc:{chips:1000000}},function (){});
	}
	setTimeout(db.close.bind(db),500);
});
