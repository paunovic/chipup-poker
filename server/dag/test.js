var dag = require('./build/Debug/dag');
console.log(dag);
dag.init();
var flop = [25,24,17];
var foo = { flop:{cards:flop},
	turn:{cards:[31]},
	river:{cards:[10]}};
console.log(dag.rankHands(foo,[{seat:5,hand:[48,2]} ]));
