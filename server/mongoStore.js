var Store = require('./node_modules/express/node_modules/connect/lib/middleware/session/store');
var MongoStore = module.exports = function MongoStore(db,collection) {
	this.table = db.collection(collection);
}
MongoStore.prototype.__proto__ = Store.prototype;
MongoStore.prototype.get = function (sid,fn) {
	this.table.findOne({_id:sid},function (err,sess) {
		if (!sess) return fn();
		expires = 'string' == typeof sess.cookie.expires ? new Date(sess.cookie.expires) : sess.cookie.expires;
		if (!expires || new Date < expires) {
			fn(null, sess);
		} else {
			self.destroy(sid, fn);
		}
	});
}
MongoStore.prototype.set = function(sid, sess, fn){
	sess._id = sid;
	this.table.save(sess,fn);
}
MongoStore.prototype.destroy = function(sid, fn){
	this.table.remove({_id:sid},fn);
}
