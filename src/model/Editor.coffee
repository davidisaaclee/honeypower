_ = require 'lodash'
Model = require './Model'
Scene = require './Scene'
Kit = require './Kit'

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
  @make: (scene, kits = []) ->
    kitSet = kits.reduce Set.put, Set.withHashProperty 'name'

    _.assign (new Editor()),
      scene: scene
      kits: kitSet

  @empty: Object.freeze Editor.make()

  @withKits: (kits = []) -> Editor.make Scene.empty, kits


  # Access

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
  @stampPrototype: (editor, protoKey) ->
    proto = Editor.getPrototype editor, protoKey
    _.assign {}, (_.omit proto, 'protoKey')


  # Mutation

  @addPrototype: (editor, protoKey, entity) ->
    entity.protoKey = protoKey
    _.assign {}, editor,
      prototypes: Set.put editor.prototypes, entity

module.exports = Editor