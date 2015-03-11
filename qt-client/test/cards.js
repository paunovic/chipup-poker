var cards = [];
for (var x=0; x<52; x++) {
	var row = x%4;
	var col = Math.floor(x/4);
	cards[x] = new Card();
	cards[x].setSize(size);
	cards[x].setPosition(0.02 + (0.07*col),0.25 + (0.15*row));
	cards[x].card = x;
}
