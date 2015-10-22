_ = require 'lodash'

###
Represents a set of related entity prototypes and game mechanics.

Kit ::=
  name: String
  prototypes: [Entity]
  physics: [PhysicsLaw] # ?
###
class Kit
  constructor: (@name, @prototypes, @physics) ->