// Generated by CoffeeScript 1.9.2
(function() {
  var _, addChildReducers;

  _ = require('lodash');

  module.exports = addChildReducers = function(baseReducer, childReducers) {
    if (childReducers == null) {
      childReducers = {};
    }
    return function(state, action) {
      var reduceOverChildren, result;
      if (state == null) {
        state = {};
      }
      reduceOverChildren = function(acc, key) {
        var changedState;
        changedState = {};
        changedState[key] = childReducers[key](acc[key], action);
        return _.assign({}, acc, changedState);
      };
      result = Object.keys(childReducers).reduce(reduceOverChildren, state);
      result = baseReducer(result, action);
      Object.freeze(result);
      return result;
    };
  };

}).call(this);

//# sourceMappingURL=addChildReducers.js.map
