_ = require 'lodash'

Model = require '../Model'
Vector2 = require './Vector2'

wrap = require '../../util/wrap'

###
Describes a two-dimensional transform.

Transform ::=
  position: Vector2
  rotation: Number
  scale: Vector2
###
class Transform extends Model
  @make: (position = Vector2.zero, rotation = 0, scale = Vector2.zero) ->
    _.assign (new Transform()),
      position: position
      rotation: rotation
      scale: scale

  @default: Object.freeze Transform.make()

  @withPosition: (position) ->
    Transform.make position


  # Access

  @getPosition: (transform) -> transform.position

  @getRotation: (transform) -> transform.rotation

  @getScale: (transform) -> transform.scale


  # Mutation

  @translate: (transform, amount) ->
    _.assign {}, transform,
      position: Vector2.add transform.position, amount

  @rotate: (transform, amount) ->
    _.assign {}, transform,
      rotate: wrap 0, 2 * Math.PI, transform.rotate + amount

  @scale: (transform, amount) ->
    _.assign {}, transform,
      # TODO: this should probably be piecewise multiply?
      scale: Vector2.add transform.scale, amount


module.exports = Transform