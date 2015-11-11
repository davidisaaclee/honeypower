_ = require 'lodash'
Lens = require 'Lens'

Model = require '../Model'
Vector2 = require './Vector2'

wrap = require '../../util/wrap'
ooChain = require '../../util/ooChain'

###
Describes a two-dimensional transform.

Transform ::=
  position: Vector2
  rotation: Number
  scale: Vector2
###
class Transform extends Model
  @make: (position = Vector2.zero, rotation = 0, scale = (Vector2.make 1, 1)) ->
    _.assign (new Transform()),
      position: position
      rotation: rotation
      scale: scale

  @default: Object.freeze Transform.make()

  @withPosition: (position) ->
    Transform.make position

  @withRotation: (rotation) ->
    Transform.make null, rotation, null

  @withScale: (scale) ->
    Transform.make null, null, scale

  # Lenses

  @position: Lens.fromPath 'position'

  @rotation: Lens.fromPath 'rotation'

  @scale: Lens.fromPath 'scale'


  # Mutation

  @applyTransform: (transformA, transformB) ->
    ooChain transformA
      .then Transform.translateBy, Transform.position.get transformB
      .then Transform.rotateBy, Transform.rotation.get transformB
      .then Transform.scaleBy, Transform.scale.get transformB
      .value()

  @translateBy: (transform, amount) ->
    Transform.position.over transform, (position) ->
      Vector2.add position, amount

  @rotateBy: (transform, amount) ->
    Transform.rotation.over transform, (rotation) ->
      wrap 0, 2 * Math.PI, rotation + amount

  @scaleBy: (transform, amount) ->
    Transform.scale.over transform, (scale) ->
      Vector2.piecewiseMultiply scale, amount


module.exports = Transform