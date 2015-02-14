//print("LOAD");
var list = input_data.split(',');
var stacks = [];
for (var x=0; x<list.length; x++) { 
	var stack = new ChipStack();
	stack.value = list[x];
	var row = Math.floor(x/5);
	var col = x % 5;

	setPos(stack,row,col);
	stacks[x] = stack;
}

var nextrow = new ChipStack();
nextrow.value = 12300;
setPos(nextrow,1,1);

function setPos(item,row,col) {
	item.setPosition(col*0.18,0.15 + (row*0.16));
	//print("put "+item.value+" at "+col*0.18+" by "+(0.15 + (row*0.15)));
}
