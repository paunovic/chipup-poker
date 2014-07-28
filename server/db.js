'use strict';
var mongoose = require('mongoose');
var Schema = mongoose.Schema, ObjectId = Schema.ObjectId;
var assert = require('assert');

mongoose.Types.ObjectId.prototype.toProtobuf = function () {
	return new Buffer(this.id,'binary');
}


var connected = false;

var models = {};
module.exports.models = models;

var User = new Schema({
	displayname:{type:String,index:{unique:true}},
	email:{type:String,index:{unique:true}},
	authcode:String,
	password:Buffer,
	salt:Buffer,
	authed:Boolean,
	forgotcode:String,
	forgottime:Number,
	newemail:String,
	changecode:String,
	changetime:Number,
	avatar:Buffer,
	currentVersion:ObjectId,
	subscription_plan:String // FIXME, add some validation and defaults
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

var ProfileSchema = new Schema({
	time:Number,
	tag:String,
	cputime:Number
},{collection:'PokerProfile',capped:1024*1024*10});

var ClubSchema = new Schema({
	is_private:Boolean,
	password:String,
	name:{type:String,index:{unique:true}},
	owner:ObjectId,
	chips:Number,
	rake:Number,
	unlimited_default_balance:Boolean,
	default_balance_limit:Number,
	members: [ObjectId],
	suspended: [ObjectId],
	seq: Number,
	testmode: Boolean
},{collection:'clubs'});
var AvatarSchema = new Schema({
	_id: String,
	image: Buffer,
	size: Number,
	created: { type: Date, default: Date.now },
	ext: String
},{collection:'avatars'});
var BugsSchema = new Schema({
	MailFrom:String,
	MailSubject:String,
	MailBody:String,
	ScreenShot:Buffer,
	BugReport:String
},{collection:'bugs'});
var DiffSchema = new Schema({
	sourcehash:String,
	desthash:String,
	size:Number,
	url:String,
},{collection:'diffs'});
var InstallerSchema = new Schema({
	name:String,
	version:String,
	revision:String,
	debug:String,
	size: Number,
	hashes: Schema.Types.Mixed,
	ts:String
},{collection:'installers'});
var ObjectSizeSchema = new Schema({
	_id:String,
	size:Number
},{collection:'objectSizes'});
var ServerErrorSchema = new Schema({
	error:String,
	trace:String,
	trace2:String
},{collection:'serverErrors'});
var IPN_HitSchema = new Schema({
	reply:String,
	params:Schema.Types.Mixed
},{collection:'IPN_hits'});
var GameSchema = new Schema({
	game_type:String,
	blinds:String,
	seats:Number,
	creator_mongo_id:ObjectId,
	clubseq:Number,
	gamename:String,
	game_limit:String,
	buyin_min:Number,
	buyin_max:Number,
	rake:Number,
	rotation:Number,
	hands:Number,
	lasthandid:Number,
	pot:Number,
	state2:String,
	gameState:Schema.Types.Mixed,
	clubid:ObjectId
},{collection:'games'});
var WinnerDataSchema = new Schema({
	seat:Number,
	msg:String
});
var PotSchema = new Schema({
	value:Number,
	members:[Number],
	trueMembers:[Number],
	trueUsers:[ObjectId],
	rake:Number,
	WinnerData:[WinnerDataSchema]
},{_id:false});
var MoveSchema = new Schema({
	code:[String],
	seat:Number,
	bet:Number,
	pots:[PotSchema],
	WinnerPotData:[PotSchema]
});
MoveSchema.path('pots').validate(function (pots) {
	return pots.length < 5;
},'too many pots');
var PlayerSchema = new Schema({
	seat:Number,
	cards:[Number],
	chips:Number,
	muck:Boolean,
	status:String
});
var HandHistorySchema = new Schema({
	seq:{type:Number,index:true},
	gameid:{type:ObjectId,index:true},
	moves:[MoveSchema],
	players:[PlayerSchema],
	cards:[Number],
	rake:Number,
	dealer:Number,
	current_game:String,
	deck:[Number],
	totalrake:Number,
	endtime:Number
},{collection:'handHistory'});
var StatsSchema = new Schema({
	gameid:ObjectId,
	userid:ObjectId,
	buyins:[Number],
	cashouts:[Number],
	secondsplayed:Number,
	balance:Number,
	rakecontrib:Number,
	hands:Number
},{collection:'allStats'});

var StateMemberSchema = new Schema({
	userid:ObjectId,
	hand:{
		cards:[Number]
	},
	status:String,
	chips:Number,
	seat:Number,
	sitOutNextRound:Boolean,
	SittingOutRoundsCount:Number,
	handsPlayed:Number,
	can_show:Boolean
},{_id:false});
var GameStateSchema = new Schema({
	pots:[PotSchema],
	current_seat:Number,
	dealer:Number,
	bets:[Number],
	state:String,
	flop:{
		cards:[Number]
	},
	turn:{
		cards:[Number]
	},
	river:{
		cards:[Number]
	},
	handid:Number,
	history:Schema.Types.Mixed,
	keycount:{type:Number,default:0},
	balance_changes:[Number],
	rake:Number,
	minBet:Number,
	minimum_raise:Number,
	members:[StateMemberSchema],
	users:[ObjectId],
	deck:[Number],
	moveCounter: Number
},{collection:'gameState'});
GameStateSchema.path('pots').validate(function (pots) {
	return pots.length < 5;
},'too many pots');

var ClubBalanceSchema = new Schema({
	clubid:ObjectId,
	userid: { type:ObjectId, required:true },
	balance:Number,
	balance_limit:Number,
	unlimited_limit:Boolean
},{collection:'clubBalances'});

var CounterSchema = new Schema({
	_id:String,
	seq:Number
},{collection:'counters'});

var PaypalRequestSchema = new Schema({
	plan:String,
	userid:ObjectId,
});
var TournamentSchema = new Schema({
	name: String,
	description: String,
	gametype: String,
	limit: String,
	seats_per_table: Number,
	minplayers: {type:Number,required:true},
	maxplayers: {type:Number,required:true},
	startingchips: {type:Number,required:true},
	timeperlevel: {type:Number,required:true},
	registered_players: { type:Number, required:true, default:0 },
	start_time: { type:Number, required:true, default: 0 },
	players: { type:[ObjectId], required:true }
});

module.exports.close = function () {
	if (!connected) return;
	mongoose.disconnect();
	connected = false;
}
module.exports.open = function (dbname) {
	if (connected) return;
	connected = true;
	mongoose.connect('mongodb://localhost/'+dbname);
	models.UserModel = mongoose.model('User',User);
	models.Admin = mongoose.model('Admin',AdminSchema);
	models.Config = mongoose.model('Config',ConfigSchema);
	models.DebugLogs = mongoose.model('DebugLogs',DebugLogSchema);
	models.Clubs = mongoose.model('Clubs',ClubSchema);
	models.Avatars = mongoose.model('Avatars',AvatarSchema);
	models.Bugs = mongoose.model('Bugs',BugsSchema);
	models.Diff = mongoose.model('Diff',DiffSchema);
	models.Installer = mongoose.model('Installer',InstallerSchema);
	models.ObjectSize = mongoose.model('ObjectSize',ObjectSizeSchema);
	models.ServerError = mongoose.model('ServerError',ServerErrorSchema);
	models.IPN_Hit = mongoose.model('IPN_Hit',IPN_HitSchema);
	models.Game = mongoose.model('Game',GameSchema);
	models.HandHistory = mongoose.model('HandHistory',HandHistorySchema);
	models.GameStats = mongoose.model('GameStats',StatsSchema);
	models.GameState = mongoose.model('GameState',GameStateSchema);
	models.PokerProfile = mongoose.model('PokerProfile',ProfileSchema);
	models.ClubBalance = mongoose.model('ClubBalance',ClubBalanceSchema);
	models.Counter = mongoose.model('Counter',CounterSchema);
	models.PaypalRequest = mongoose.model('PaypalRequest',PaypalRequestSchema);
	models.Tournament = mongoose.model('Tournament',TournamentSchema);
}

if (require.main === module) {
	models.Counter.findOne({_id:'test'},function (err,docs) {
		assert.ifError(err);
		console.log(docs);
	});
}

