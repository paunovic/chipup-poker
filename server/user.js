var models = require('./db').models;
var crypto = require('crypto');
var deck = require('./deck');

module.exports.ChangePassword = ChangePassword;

function ChangePassword(new_password,userid,cb) {
	// FIXME, refactor into a dedicated function and add a test
	deck.getRandom(16,function changePw_cb1(salt) {
		var hasher = crypto.createHash('sha256');
		hasher.update(salt);
		hasher.update(new_password);
		var hash = hasher.digest();
		models.UserModel.findOne({_id:userid},function changePw_cb2(err,self) {
			self.password = hash;
			self.salt = salt;
			self.save(cb);
		}.bind(this));
	}.bind(this));
}
