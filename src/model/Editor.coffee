_ = require 'lodash'
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
  @make: (scene = Scene.empty, kits = []) ->
    kitSet = kits.reduce Set.put, Set.withHashProperty 'name'

    _.assign (new Editor()),
      scene: scene
      kits: kitSet

  @empty: Object.freeze Editor.make()

  @withKits: (kits = []) -> Editor.make Scene.empty, kits


  # Access

  @getScene: (editor) -> editor.scene

  @getPrototype: (editor, protoKey) ->
    results = Set.asArray editor.kits
      .map (kit) -> Kit.getPrototype kit, protoKey
      .filter (x) -> x?

    switch results.length
      when 0
        undefined
      when 1
        results[0]
      else
        console.warn 'More than one prototype with key', protoKey
        results[0]


  # Creates a stamped copy of the specified prototype entity.
  #
  #   editor [Editor] - invoking `Editor`
  #   protoKey [String] - the `Prototype`'s registered key
  #   transform [Transform]
  #   [name [String]] - a name for the new stamped `Entity`
  #   [id [String]] - a user-defined id for the new `Entity`
  @stampPrototype: (editor, protoKey, transform, name, id) ->
    proto = Editor.getPrototype editor, protoKey
    # _.assign {}, (_.omit proto, 'protoKey')
    Prototype.stamp proto, transform, name, id


  # Mutation

  @setScene: (editor, scene) ->
    _.assign {}, editor, scene: scene

  @mutateScene: (editor, mutator) ->
    Editor.setScene editor, mutator Editor.getScene editor

  @addPrototype: (editor, protoKey, entity) ->
    entity.protoKey = protoKey
    _.assign {}, editor,
      prototypes: Set.put editor.prototypes, entity

module.exports = Editor