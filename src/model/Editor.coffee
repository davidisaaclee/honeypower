_ = require 'lodash'
Model = require './Model'

Set = require '../util/Set'

###
Represents the application view for creating and editing Scenes.

Editor ::=
  # The Scene being modified.
  scene: Scene
  # # Entity prototypes which can be copied onto the scene and modified.
  # prototypes: [Entity]

  # All active Kits.
  kits: { id -> Kit }
###
class Editor extends Model
  @make: (scene, prototypes = Set.withHashFunction ({protoKey}) -> protoKey) ->
    _.assign (new Editor()),
      scene: scene
      prototypes: prototypes

  @empty: Object.freeze Editor.make()


  # Access

  @getPrototype: (editor, protoKey) ->
    Set.get editor.prototypes, protoKey

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