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
  #   [id [String]] - optional user-defined id
  @stamp: (proto, transform, name, id) ->
    Entity.make name,
      transform,
      proto.entity.children,
      # proto,      # is it worthwhile to pass around the prototype?
      id


  # Access

  @getDefinition: (proto) -> proto.entity


module.exports = Prototype