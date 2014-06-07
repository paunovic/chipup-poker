var ObjectID = require('mongodb').ObjectID;

module.exports.toMongoId = toMongoId;
module.exports.fromMongoId = fromMongoId;
module.exports.compareObjectID = compareObjectID;
function toMongoId(buf) {
	return new ObjectID(buf.toString('hex'));
}
function fromMongoId(id) {
	return new Buffer(id.id,'binary');
}
function compareObjectID(a,b) {
	if (!b) return false;
	var astr = a.toString();
	var bstr = b.toString();
	return astr == bstr;
}
