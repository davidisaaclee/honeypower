_ = require 'lodash'
Model = require './Model'
Set = require '../util/Set'

###
Represents a set of related entity prototypes, inspector views, and game
  mechanics.

Kit ::=
  name: String
  prototypes: [String]
  physics: [String] # ?
  inspectors: [String] # ?
###
class Kit extends Model
  @make: (name, options) ->
    options = _.defaults options,
      prototypes: Set.withHashProperty 'name'
      physics: Set.withHashProperty 'name'
      inspectors: Set.withHashProperty 'name'
      name: name
    _.assign (new Kit()), options

  @with: (name, prototypes = [], physics = [], inspectors = []) ->
    Kit.make name,
      prototypes: Set.withHashProperty 'name', prototypes
      physics: Set.withHashProperty 'name', physics
      inspectors: Set.withHashProperty 'name', inspectors


  # Access

  @getPrototypes: (kit) -> kit.prototypes

  @getPhysics: (kit) -> kit.physics

  @getInspectors: (kit) -> kit.inspectors


  @getPrototype: (kit, prototypeName) ->
    Set.get kit.prototypes, prototypeName

  @getInspector: (kit, inspectorId) ->
    Set.get Kit.getInspectors, inspectorId

module.exports = Kit