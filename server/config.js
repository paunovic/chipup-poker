var fs = require("fs");

var config = JSON.parse(fs.readFileSync(process.env.CONFIG_FILE));
module.exports = config;
