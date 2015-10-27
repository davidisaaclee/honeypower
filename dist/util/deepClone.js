// Generated by CoffeeScript 1.9.2
(function() {
  var _, deepClone;

  _ = require('lodash');

  module.exports = deepClone = function(obj) {
    var result;
    result = _.clone(obj);
    switch (obj.constructor) {
      case Object:
        return _.mapValues(result, function(value, key) {
          return deepClone(value);
        });
      case Array:
        return _.map(result, function(value) {
          return deepClone(value);
        });
      default:
        return result;
    }
  };

}).call(this);

//# sourceMappingURL=deepClone.js.map
