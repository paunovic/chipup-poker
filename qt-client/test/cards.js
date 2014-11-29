var cards = [];
for (var x=0; x<52; x++) {
	var row = x%4;
	var col = Math.floor(x/4);
	cards[x] = new Card();
	cards[x].setPosition(0.2 + (0.05*col),0.25 + (0.15*row));
	cards[x].setSize(0.1);
	cards[x].card = x;
}