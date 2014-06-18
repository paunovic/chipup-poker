var mongoose = require('mongoose');
var Schema = mongoose.Schema, ObjectId = Schema.ObjectId;
var assert = require('assert');


var connected = false;

var models = {};
module.exports.models = models;

var User = new Schema({
	displayname:String,
	email:String,
	authcode:String,
	password:Buffer,
	salt:Buffer,
	authed:Boolean,
	chips:Number,
	forgotcode:String,
	forgottime:Number,
	newemail:String,
	changecode:String,
	changetime:Number
});

var AdminSchema = new Schema({
	username:String,
	password:Buffer,
	salt:Buffer
},{collection:'admin'});

var ConfigSchema = new Schema({
	_id:String,
	value:ObjectId
},{collection:'config'});

var DebugLogSchema = new Schema({
	type:String,
	msg:String,
	nick:String,
	connid:Number,
	objects:Array,
	gameid:ObjectId,
	name:String
},{collection:'debugLogs',capped:1024 * 1024*32});

var ClubSchema = new Schema({
	is_private:Boolean,
	password:String,
	name:String,
	owner:ObjectId,
	chips:Number,
	rake:Number,
	unlimited_default_balance:Boolean,
	default_balance_limit:Number,
	members: [ObjectId],
	suspended: [ObjectId]
},{collection:'clubs'});

module.exports.close = function () {
	if (!connected) return;
	mongoose.disconnect();
	connected = false;
}
module.exports.open = function () {
	if (connected) return;
	connected = true;
	mongoose.connect('mongodb://localhost/poker');
	models.UserModel = mongoose.model('User',User);
	models.Admin = mongoose.model('Admin',AdminSchema);
	models.Config = mongoose.model('Config',ConfigSchema);
	models.DebugLogs = mongoose.model('DebugLogs',DebugLogSchema);
	models.Clubs = mongoose.model('Clubs',ClubSchema);
}

if (require.main === module) {
	models.Admin.find({},function (err,docs) {
		assert.ifError(err);
		console.log(docs);
	});
}

module.exports.open();
