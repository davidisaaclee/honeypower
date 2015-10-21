_ = require 'lodash'
Model = require '../Model'
Vector2 = require '../graphics/Vector2'
Path = require '../graphics/Path'


###
Describes a "hotspot" which triggers an action when entered by an entity.

Trigger ::=
  # The origin of this trigger's local coordinate system.
  position: Vector2
  # The shape of the trigger, in local space.
  shape: Path
  # The action to perform upon trigger activation.
  action: Function
###
class Trigger extends Model
  @make: (position = Vector2.zero, shape = Path.empty, action = (->)) ->
    _.assign (new Trigger()),
      position: position
      shape: shape
      action: action

module.exports = Trigger