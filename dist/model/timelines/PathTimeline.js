// Generated by CoffeeScript 1.9.2
(function() {
  var Lens, Path, PathTimeline, Timeline, Transform, Vector2, _,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  Lens = require('lens');

  Timeline = require('./Timeline');

  Path = require('../graphics/Path');

  Vector2 = require('../graphics/Vector2');

  Transform = require('../graphics/Transform');

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

    PathTimeline.path = Lens.fromPath('data.path');


    /*
    Modifies the provided `data` according to the timeline's `progress`.
    
      timeline: Timeline - the invoking `PathTimeline`
      progress: Float - a number between 0 and 1, the progress of the timeline.
      data: Object - arbitrary data to be modified
      returns a modified copy of `data`
     */

    PathTimeline.mapping = function(timeline, progress, data) {
      var delta, dst;
      dst = Path.pointAt(PathTimeline.path.get(timeline), progress);
      delta = Vector2.subtract(dst, Transform.position.get(data.transform));
      return _.assign({}, data, {
        transform: Transform.translateBy(data.transform, delta)
      });
    };

    return PathTimeline;

  })(Timeline);

  module.exports = PathTimeline;

}).call(this);

//# sourceMappingURL=PathTimeline.js.map
