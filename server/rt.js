#!/usr/bin/env node

var https = require('https');

function requestTracker(user,pass) {
  this.user = user;
  this.pass = pass;
}
requestTracker.prototype.rest = function test(url,args,cb) {
  var auth = new Buffer(this.user + ":" + this.pass).toString("base64");
  var body = JSON.stringify(args);
  var obj = {
    hostname: "api.github.com",
    path: url,
    method: "POST",
    headers:{
      Authorization: "Basic " + auth,
      "User-Agent": "https://github.com/cleverca22/chipuppoker",
      "Content-Length": body.length
    },
  };
  var req = https.request(obj, function(err, response) {
    console.log('response: ', arguments);
    if (cb) cb();
  });
  req.on("error", function(e) {
    console.log('rest error',e);
    cb(e);
  });
  req.write(body);
}

requestTracker.prototype.createTicket = function (obj,cb) {
  var out = [];
  for (var key in obj) {
    out.push(key+': '+(obj[key].replace(/\n/g,'\n ')));
  }
  out = out.join('\n');
  var data = 'content='+escape(out);
  console.log(data);
  this.rest('ticket/new',data,cb);
}

//login('root','password');

function postTicket(email, title, body, cb) {
  console.log('email is "%s"',email);
  var rt = new requestTracker('cleverca22-hydra','7eb1a41b8fa4b3f7aa6f9db588392e0307e7a861');
  rt.rest('/repos/cleverca22/chipuppoker/issues', {title: title, body:"From: " + email + "\n" + body },cb);
}
module.exports.postTicket = postTicket;

if (require.main === module) {
  postTicket("user@example.com", "title", "body");
}
