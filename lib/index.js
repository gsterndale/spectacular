// Generated by CoffeeScript 1.6.2
var Runner, fs, k, m, matchers, path, v, vm;

m = require('module');

fs = require('fs');

vm = require('vm');

path = require('path');

Runner = require('./runner');

['factories', 'spectacular'].forEach(function(file) {
  var filename, src;

  filename = path.resolve(__dirname, "" + file + ".js");
  src = fs.readFileSync(filename);
  return vm.runInThisContext(src, filename);
});

matchers = require('./matchers');

for (k in matchers) {
  v = matchers[k];
  global[k] = v;
}

exports.run = function(options) {
  return new Runner(rootExampleGroup, options).run();
};