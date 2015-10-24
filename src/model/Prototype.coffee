_ = require 'lodash'
Model = require './Model'
Entity = require './entities/Entity'

###
Encapsulates an `Entity` for stamping/reuse.

Prototype ::=
  name: String
  entity: Entity
###
class Prototype extends Model
  @make: (name, entity) ->
    _.assign (new Prototype()),
      name: name
      entity: entity

  # Create a copy of `proto`'s entity, with reference back to `proto`.
  #
  #   proto [Prototype] - the invoking `Prototype`
  #   name [String] - the name of the to-be-created copy
  @stamp: (proto, name) ->
    Entity.make name,
      proto.entity.transform,
      proto.entity.children,
      proto


  # Access

  @getDefinition: (proto) -> proto.entity


module.exports = Prototype