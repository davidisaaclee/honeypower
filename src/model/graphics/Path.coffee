_ = require 'lodash'
Model = require '../Model'
Vector2 = require './Vector2'


###
Describes a path of line segments.

Path ::=
  # The origin of this path's local coordinate system.
  position: Vector2
  # The segments comprising this path.
  segments: [Vector2] # ?
###
class Path extends Model
  @make: (position = Vector2.zero, segments = []) ->
    _.assign (new Path()),
      position: position
      segments: segments

  @empty: Object.freeze Path.make()


  # Access

  @checkCollision: (pathA, pathB) ->
    # TODO


  # Mutation

  @addSegment: (path, segment) ->
    _.assign {}, path,
      segments: [path.segments..., segment]