// Generated by CoffeeScript 1.9.2
(function() {
  var Lens, Set, _;

  _ = require('lodash');

  Lens = require('lens');


  /*
  Simple immutable set implementation.
   */

  Set = (function() {
    function Set(hashFunction, elementDict) {
      if (hashFunction == null) {
        hashFunction = Object.prototype.toString;
      }
      if (elementDict == null) {
        elementDict = {};
      }
      this._hash = hashFunction;
      this._elements = elementDict;
    }

    Set.withHashFunction = function(hashFunction, initial) {
      var set;
      if (initial == null) {
        initial = [];
      }
      set = new Set(hashFunction, Object.freeze({}));
      return initial.reduce(Set.put, set);
    };

    Set.withHashProperty = function(hashProperty, initial) {
      var set;
      if (initial == null) {
        initial = [];
      }
      set = new Set(_.property(hashProperty), Object.freeze({}));
      return initial.reduce(Set.put, set);
    };

    Set.element = Lens.fromPath(function(hash) {
      return ['_elements', hash];
    });

    Set.asArray = new Lens(function(set) {
      return _.values(set._elements);
    }, function(set, array) {
      return array.reduce(Set.put, Set.clear(set));
    });

    Set.get = function(set, hash) {
      return Set.element.get(set, hash);
    };

    Set.contains = function(set, element) {
      return (Set.element.get(set, set._hash(element))) != null;
    };

    Set.count = function(set) {
      return (Object.keys(set._elements)).length;
    };

    Set.find = function(set, predicate) {
      return _.find(Set.asArray.get(set), predicate);
    };

    Set.keys = function(set) {
      return Object.keys(set._elements);
    };

    Set.put = function(set, element) {
      return Set.element.set(set, set._hash(element), element);
    };

    Set.remove = function(set, element) {
      return Set.removeByHash(set, set._hash(element));
    };

    Set.removeByHash = function(set, hash) {
      return _.assign({}, set, {
        _elements: _.omit(set._elements, hash)
      });
    };

    Set.clear = function(set) {
      return (Set.asArray.get(set)).reduce(Set.remove, set);
    };

    return Set;

  })();

  module.exports = Set;

}).call(this);

//# sourceMappingURL=Set.js.map
