module.exports.Pot = Pot;

function Pot(game) {
	this.value = 0;
	this.members = []
	this.trueMembers = []
	this.trueUsers = [];
}
Pot.prototype.getPostRake = function (rake) {
	return Math.floor(this.value * ((100 - rake)/100)); // FIXME, double check the math
}
Pot.prototype.add = function (bet,seat,game) {
	this.value += bet;

	if (this.trueMembers.indexOf(seat) == -1) {
		this.trueMembers.push(seat);
		this.trueUsers.push(game.seats[seat].userid);
	}

	if (this.members.indexOf(seat) != -1) return;
	var pub = game.members[seat];
	if (!pub) return; // he stood up
	if (pub.status == 'psFolded') return;
	this.members.push(seat);
}

