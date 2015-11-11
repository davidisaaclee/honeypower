// Generated by CoffeeScript 1.9.2
(function() {
  var Set, checkCollisions;

  Set = require('../util/Set');

  checkCollisions = function(scene) {
    var entityArray;
    if (scene.constructor.name !== 'Scene') {
      throw new Error('checkCollisions() supplied a non-Scene input.');
    }
    entityArray = Set.asArray.get(scene.entities);
    return entityArray.map(function(entityA, idx) {
      if (idx !== (entityArray.length - 1)) {
        return (entityArray.splice(idx + 1)).map(function(entityB) {
          return {
            entityA: entityA,
            entityB: entityB,
            collision: Entity.checkCollision(entityA, entityB)
          };
        });
      }
    }).reduce((function(a, b) {
      return a.concat(b);
    }), []).filter(function(x) {
      return x.collision != null;
    });
  };

}).call(this);

//# sourceMappingURL=CollisionController.js.map
