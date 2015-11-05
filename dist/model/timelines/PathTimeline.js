// Generated by CoffeeScript 1.9.2
(function() {
  var Path, PathTimeline, Timeline, _,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  Timeline = require('./Timeline');

  Path = require('../graphics/Path');

  PathTimeline = (function(superClass) {
    extend(PathTimeline, superClass);

    function PathTimeline() {
      return PathTimeline.__super__.constructor.apply(this, arguments);
    }

    PathTimeline.make = function(path) {
      return _.assign(new PathTimeline(), {
        "class": 'PathTimeline',
        path: path
      });
    };


    /*
    Modifies the provided `entity` according to the timeline's `progress`.
    
      timeline - the invoking `PathTimeline`
      progress: Float - a number between 0 and 1, the progress of the timeline.
      entity: Entity
      returns a modified copy of `entity`
     */

    PathTimeline.mapping = function(timeline, progress, entity) {
      var delta, dst;
      dst = Path.pointAt(timeline.path, progress);
      delta = Vector2.subtract(dst, Entity.getPosition(entity));
      return Entity.translate(entity, delta);
    };

    return PathTimeline;

  })(Timeline);

  module.exports = PathTimeline;

}).call(this);

//# sourceMappingURL=PathTimeline.js.map