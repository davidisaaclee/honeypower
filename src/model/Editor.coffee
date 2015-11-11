_ = require 'lodash'
Lens = require 'lens'
Model = require './Model'
Scene = require './Scene'
Kit = require './Kit'
Prototype = require './Prototype'

Set = require '../util/Set'

###
Represents the application view for creating and editing Scenes.

Editor ::=
  # The Scene being modified.
  scene: Scene

  # All active Kits.
  kits: { id -> Kit }
###

class Editor extends Model

EditorFns =
  make: (scene = Scene.empty, kits = []) ->
    kitSet = kits.reduce Set.put, Set.withHashProperty 'name'

    _.assign (new Editor()),
      scene: scene
      kits: kitSet

  withKits: (kits = []) -> EditorFns.make Scene.empty, kits


  ### Lenses ###

  scene: Lens.fromPath 'scene'

  proto: do ->
    getter = (model, key) ->
      results = Set.asArray.get model.kits
        .map (kit) -> Kit.proto.get kit, key
        .filter (x) -> x?

      switch results.length
        when 0
          undefined
        when 1
          results[0]
        else
          console.warn 'More than one prototype with key', key
          results[0]
    return new Lens getter, null


  ### Mutation ###

  # Creates a stamped copy of the specified prototype entity.
  #
  #   editor [Editor] - invoking `Editor`
  #   protoKey [String] - the `Prototype`'s registered key
  #   transform [Transform]
  #   [name [String]] - a name for the new stamped `Entity`
  #   [id [String]] - a user-defined id for the new `Entity`
  stampPrototype: (editor, protoKey, transform, name, id) ->
    proto = EditorFns.proto.get editor, protoKey
    Prototype.stamp proto, transform, name, id



# Self-referential properties
_.assign EditorFns,
  empty: Object.freeze EditorFns.make()


module.exports = EditorFns