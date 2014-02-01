var dag = require('./build/Release/dag');
dag.init();
var flop = [{value:8,suit:'S'},{value:8,suit:'H'},{value:6,suit:'S'}];
var foo = { flop:{cards:flop},
	turn:{cards:[{value:9,suit:'D'}]},
	river:{cards:[{value:4,suit:'C'}]}};
console.log(dag.rankHands(foo,[{seat:5,hand:[{value:1,suit:'H'},{value:2,suit:'C'}]} ]));
