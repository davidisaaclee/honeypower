_ = require 'lodash'
Model = require '../Model'
Vector2 = require '../graphics/Vector2'
Path = require '../graphics/Path'


###
Describes a "hotspot" which triggers an action when entered by an entity.
###
class Trigger extends Model
  @make: (position = Vector2.zero, path = Path.empty, action = (->)) ->
    _.assign (new Trigger()),
      position: position
      path: path
      action: action

module.exports = Trigger