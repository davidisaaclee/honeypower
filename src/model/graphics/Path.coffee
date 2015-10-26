_ = require 'lodash'
Model = require '../Model'
Vector2 = require './Vector2'

ooChain = require '../../util/ooChain'
pairs = require '../../util/pairs'

# Calculate the polyline connecting all points in `points`.
calculateLength = (points) ->
  pairs points
    .map ([src, dst]) ->
      Vector2.subtract dst, src
    .reduce _.add, 0

###
Describes an ordered path of points.

Path ::=
  # The origin of this path's local coordinate system.
  position: Vector2

  # The points comprising this path, relative to `position`.
  points: [Vector2]

  # The length of the polyline connecting all points.
  length: Number
###
class Path extends Model
  @make: (position = Vector2.zero, points = []) ->
    _.assign (new Path()),
      position: position
      points: points
      length: calculateLength points

  @empty: Object.freeze Path.make()


  # Access

  # Gets the start point of `path`.
  #
  #     Path.pointAt p, 0 == Path.start p
  @start: (path) -> _.head path.points


  # Gets the end point of `path`.
  #
  #     Path.pointAt p, 1 == Path.start p
  @start: (path) -> _.last path.points


  @checkCollision: (pathA, pathB) ->
    # TODO


  ###
  Calculates the point at the given position on the path.

    path: the invoking `Path`.
    position: a float between 0 and 1; the position along the path.
  ###
  @pointAt: (path, position) ->
    scaledPosition = path.length * position
    segments = pairs path.points

    moved = 0
    targetSegment = null
    for [src, dst] in segments
      dist = Vector2.subtract dst, src
      if moved + dist > scaledPosition
        targetSegment = [src, dst]
        break
      else moved += dist

    if targetSegment?
      [src, dst] = targetSegment
      ooChain dst
        .then Vector2.subtract, src
        .then Vector2.scale, position - moved
        .then Vector2.add, src
        .value()
    else
      # outside positive bounds; return end point
      return Path.end path



  # Mutation

  @addPoint: (path, point) ->
    _.assign {}, path,
      points: [path.points..., point]


module.exports = Path