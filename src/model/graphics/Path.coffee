_ = require 'lodash'
Lens = require 'Lens'

Model = require '../Model'
Vector2 = require './Vector2'

ooChain = require '../../util/ooChain'
pairs = require '../../util/pairs'

# Calculate the polyline connecting all points in `points`.
calculateLength = (points) ->
  pairs points
    .map ([src, dst]) -> Vector2.subtract dst, src
    .map (displacement) -> Vector2.magnitude.get displacement
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
  @make: () ->
    args = switch
      when arguments.length >= 2
        position: arguments[0], points: arguments[1]
      when arguments.length is 1
        points: arguments[0]
      else {}

    args = _.defaults args,
      position: Vector2.zero
      points: []

    _.assign (new Path()),
      position: args.position
      points: args.points
      length: calculateLength args.points

  @empty: Object.freeze Path.make()


  # Lenses

  @point: Lens.fromPath (idx) -> [ 'points', idx ]

  @start: Lens.fromPath 'points.0'

  @end: new Lens \
    (path) -> _.last path.points,
    (path, v) -> [(_.initial path.points)..., v]


  ###
  Calculates the point at the given position on the path.

    path: the invoking `Path`.
    position: a float between 0 and 1; the position along the path.
  ###
  @pointAt: (path, position) ->
    distanceLeft = path.length * position
    segments = pairs path.points

    targetSegment = _.find segments, ([src, dst]) ->
      dist = Vector2.magnitude.get Vector2.subtract dst, src
      nextDistanceLeft = distanceLeft - dist
      if nextDistanceLeft < 0
        return true
      else
        distanceLeft = nextDistanceLeft
        return false

    if targetSegment?
      [src, dst] = targetSegment
      ooChain dst
        .then Vector2.subtract, src
        .then Vector2.magnitude.set, distanceLeft
        .then Vector2.add, src
        .value()
    else
      # outside positive bounds; return end point
      return Path.end.get path



  # Mutation

  @addPoint: (path, point) ->
    _.assign {}, path,
      points: [path.points..., point]


module.exports = Path