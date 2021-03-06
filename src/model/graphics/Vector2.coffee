_ = require 'lodash'
Lens = require 'lens'

Model = require '../Model'

###
Represents a 2D vector.

Vector2 ::=
  x: Number
  y: Number
###
class Vector2 extends Model
  @make: (x, y) ->
    _.assign (new Vector2()),
      x: x
      y: y

  @zero: Object.freeze (Vector2.make 0, 0)


  ### Lenses ###

  @x: Lens.fromPath 'x'

  @y: Lens.fromPath 'y'

  @magnitude: new Lens \
    (v) -> Math.sqrt Vector2.squaredMagnitude v,
    (v, m) -> Vector2.scale (Vector2.normalize v), m


  ### Operations ###

  @squaredMagnitude: (v) ->
    v.x * v.x + v.y * v.y

  @add: (v1, v2) ->
    Vector2.make \
      v1.x + v2.x,
      v1.y + v2.y

  @subtract: (v1, v2) ->
    Vector2.add v1, (Vector2.negate v2)

  @scale: (v, n) ->
    Vector2.make \
      v.x * n,
      v.y * n

  @negate: (v) ->
    Vector2.make -v.x, -v.y

  @piecewiseMultiply: (v1, v2) ->
    Vector2.make \
      v1.x * v2.x,
      v1.y * v2.y

  @normalize: (v) ->
    Vector2.scale v, (1 / Vector2.magnitude.get v)


module.exports = Vector2