var fs = require('fs');
var async = require('async');
var assert = require('assert');
var child_process = require('child_process');
var crypto = require('crypto');
var https = require('https');
var temp = require('temp');

var config = require('./config');
var models = require('./db').models;

module.exports.unpackInstaller = unpackInstaller;
module.exports.copyFile = copyFile;
module.exports.recurse_dir = recurse_dir;
module.exports.unpackTar = unpackTar;

function updateLive(doc,sizes,cb) {
  var body = new Buffer(JSON.stringify({installer:doc,sizes:sizes}));
  var req = https.request({host:'chipuppoker.com',method:'POST',path:'/sync/newVersion',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
  req.on('data',function (chunk) {
    console.log(chunk);
  });
  req.on('error',function (err) {
    console.log('http error sending new version:',err);
  });
  req.write(body);
  req.end();
  cb();
}

function unpackInstaller(record,cb1) {
  var prefix = config.unpacked + '/'+record._id+'/app/';
  var unpacker = child_process.spawn('innoextract', ['-l', '-d', config.unpacked + '/'+record._id+'/', '-e', config.installers + '/'+record.name ], {stdio:'inherit'});
  unpacker.on('close',function (code, err) {
    console.log('result',arguments);
    if (code != 0) {
      cb1(false);
      return;
    }
    assert.equal(code, 0);
    recurse_dir('',prefix,function (err,files) {
      assert.ifError(err);
      console.log('all files:%j',files);
      hashFiles(prefix,files,function (hashes,sizes) {
        record.hashes = hashes;
        record.save(function (err,newdoc) {
          assert.ifError(err);
          if (err) console.log(err);
          console.log('inserted %j',newdoc);
          deleteDir(config.unpacked + '/'+record._id);
          async.each(sizes,function (row,cb) {
            models.ObjectSize.create(row,cb);
          },function () {
            cb1(true);
          });
        });
      });
    });
  });
}

function deleteDir(path,cb1) {
  if (fs.existsSync(path)) {
    fs.readdir(path,function (err,files) {
      async.each(files,function (item,cb) {
        fs.lstat(path+"/"+item,function (err,stats) {
          if (stats.isDirectory()) {
            deleteDir(path+"/"+item,cb);
          } else {
            fs.unlink(path+"/"+item,cb);
          }
        });
      },function () {
        fs.rmdir(path);
        if (cb1) cb1();
      });
    });
  }
}

function unpackTar(record,localFile,cb1) {
  temp.mkdir('unpack',function (err,dirPath) {
    console.log(dirPath);
    var child = child_process.spawn('tar',['-xf',localFile,'-C',dirPath],{stdio:'inherit'});
    child.on('close',function (code) {
      console.log('child exited with code',code);
      if (code == 0) {
        recurse_dir('',dirPath+'/chipuppoker.app/',function (err,files) {
          assert.ifError(err);
          console.log('all files:%j',files);
          hashFiles(dirPath+'/chipuppoker.app/',files,function (hashes,sizes) {
            record.hashes = hashes;
            record.save(function (err,newdoc) {
              assert.ifError(err);
              if (err) console.log(err);
              deleteDir(dirPath);
              async.each(sizes,function (row,cb) {
                models.ObjectSize.create(row,cb);
              },function () {
                updateLive(record,sizes,function () {
                  cb1(true);
                });
              });
            });
          });
        });
      } else {
        cb1(false);
      }
    });
  });
}

function hashFiles(prefix,files,cb) {
  var hashes = {};
  var sizes = [];
  async.each(files,function hashFile(filename,cb2) {
    var hasher = crypto.createHash('sha256');
    var client = fs.createReadStream(prefix+filename);
    var size = 0;
    client.on('data',function (data) {
      hasher.update(data);
      size += data.length;
    });
    client.on('end',function () {
      var hash = hasher.digest('hex');
      //console.log('hash of %s is %s',filename,hash);
      var key = filename.replace('.',':').replace('.',':');
      sizes.push({_id:hash, size:size});
      hashes[key] = hash;
      copyFile(prefix+filename, config.unpacked + '/objects/'+hash,function () {
        fs.unlink(prefix+filename,function () {
          cb2();
        });
      });
    });
  },function () {
    cb(hashes,sizes);
  });
}

function copyFile(source,dest,cb) {
  fs.stat(dest,function (err,stat) {
    if (stat) return cb();

    var input = fs.createReadStream(source);
    var output = fs.createWriteStream(dest);
    input.pipe(output);
    input.on('end',cb);
  });
}

function recurse_dir(path,prefix,cb4) {
  var items = [];
  fs.readdir(prefix+path,function (err,files) {
    console.log('checked path %s %s',prefix,path,files);
    assert.ifError(err);
    async.eachLimit(files,1,function checkItem(filename,cb3) {
      //if (filename == 'Current') return cb3();
      fs.lstat(prefix+path+filename,function (err,stats) {
        assert.ifError(err);
        //console.log('stats:%j',stats);
        if (stats.isSymbolicLink()) {
          console.log('%s is a symlink',filename);
          cb3();
        } else if (stats.isDirectory()) {
          console.log("%s is a directory",filename);
          recurse_dir(path+filename+'/',prefix,function (err,items2) {
            console.log('2nd level %j',items2);
            assert.ifError(err);
            items = items.concat(items2);
            cb3();
          });
        } else if (stats.isFile()) {
          console.log('%s is a file',filename);
          items.push(path+filename);
          cb3();
        }
      });
    },function () {
      cb4(null,items);
    });
  });
}
