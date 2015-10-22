_ = require 'lodash'
Entity = require './Entity'

###
Represents a sprited `Entity`.

Character ::=
  name: String
  transform: Transform
  children: [Entity]
  spriteId: String
###
class Character extends Entity
  @make: (name, transform, children, spriteId) ->
    _.assign (new Character()),
      name: name
      transform: children
      spriteId: spriteId