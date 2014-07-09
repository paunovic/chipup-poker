var models = require('./db').models;
process.on('uncaughtException',function (err) {
	console.log(err);
	console.log(err.stack);
	handleError(err);
});
function handleError(err,tracer) {
	if (!err) return;
	// FIXME, maybe report the error to master sync style, and then insta-fail?
	var trace = '';
	if (err.stack) trace = err.stack.split('\n').slice(1).join('\n').trim();
	if (!tracer) tracer = new Error();
	var trace2 = tracer.stack;
	models.ServerError.create({error:err.toString(),trace:trace,trace2:trace2},function (err) {
		if (err) console.log(err);
		process.exit(-1);
	});
}
module.exports.handleError = handleError;
