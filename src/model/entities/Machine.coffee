_ = require 'lodash'
Entity = require './Entity'

###
Represents an `Entity` which can be applied to other `Entity`s.

Machine ::=
  name: String
  transform: Transform
  children: [Entity]
  # TODO: Machines, states? Hm?
  spriteIds: { state -> String }
  state: String
###

class Machine extends Entity
  @make: null