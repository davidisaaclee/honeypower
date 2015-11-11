_ = require 'lodash'
Lens = require 'lens'
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


  # Lenses

  @allPrototypes: Lens.fromPath 'prototypes'

  @allPhysics: Lens.fromPath 'physics'

  @allInspectors: Lens.fromPath 'inspectors'

  @proto: do ->
    composed = Lens.compose Kit.allPrototypes, Set.element
    new Lens \
      (kit, key) -> composed.get kit, [], [key],
      (kit, key, val) -> composed.get kit, [], [key], val

  @inspector: do ->
    composed = Lens.compose Kit.allInspectors, Set.element
    return new Lens \
      (kit, inspectorId) -> composed.get kit, [], [inspectorId],
      (kit, inspectorId, val) -> composed.set kit, [], [inspectorId], val

module.exports = Kit