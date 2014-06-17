var mongoose = require('mongoose');
var Schema = mongoose.Schema, ObjectId = Schema.ObjectId;
var assert = require('assert');

mongoose.connect('mongodb://localhost/poker');

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
models.UserModel = mongoose.model('User',User);

var AdminSchema = new Schema({
	username:String,
	password:Buffer,
	salt:Buffer
},{collection:'admin'});
models.Admin = mongoose.model('Admin',AdminSchema);

var ConfigSchema = new Schema({
	_id:String,
	value:ObjectId
},{collection:'config'});
models.Config = mongoose.model('Config',ConfigSchema);

var DebugLogSchema = new Schema({
	type:String,
	msg:String,
	nick:String,
	connid:Number,
	objects:Array,
	gameid:ObjectId,
	name:String
},{collection:'debugLogs'});
models.DebugLogs = mongoose.model('DebugLogs',DebugLogSchema);

module.exports.close = function () {
	mongoose.disconnect();
}

if (require.main === module) {
	models.Admin.find({},function (err,docs) {
		assert.ifError(err);
		console.log(docs);
	});
}
