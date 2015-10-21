_ = require 'lodash'
u = require 'updeep'
Model = require './Model'
Set = require '../util/Set'

###
The main state of an interactive scene.

Scene ::=
  # Entity database, mapping entity unique IDs to model.
  entities: { String -> Entity }
###
class Scene extends Model
  @make: (entities) ->
    _.assign (new Scene()),
      entities: entities

  @empty: Object.freeze Scene.make (Set.withHashFunction ({id}) -> id)


  # Access

  @getEntity: (scene, entityId) ->
    Set.get scene.entities, entityId

  @getEntityByName: (scene, entityName) ->
    Set.find scene.entities, name: entityName

  @getAllEntityIds: (scene) ->
    Object.keys Set.asObject scene.entities

  @getAllEntities: (scene) ->
    Set.asArray scene.entities


  # Mutation

  @addEntity: (scene, entity) ->
    _.assign {}, scene,
      entities: Set.put scene.entities, entity

  @removeEntity: (scene, entityId) ->
    _.assign {}, scene,
      entities: Set.remove scene.entities, entity

module.exports = Scene