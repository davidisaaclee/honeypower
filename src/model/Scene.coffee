_ = require 'lodash'
u = require 'updeep'
Model = require './Model'
Entity = require './entities/Entity'
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

  @empty: Object.freeze Scene.make (Set.withHashProperty 'id')


  # Access

  @getEntity: (scene, entityId) ->
    Set.get scene.entities, entityId

  @getEntityById: @getEntity

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
      entities: Set.remove scene.entities, (Set.get scene.entities, entityId)

  @linkEntitiesById: (scene, parentId, childId) ->
    parent = Scene.getEntity scene, parentId
    child = Scene.getEntity scene, childId

    if parent? and child?
      newScene = scene
      newScene = Scene.mutateEntity newScene, parent.id, (e) ->
        Entity.setChild e, child
      return newScene
    else
      offendingIds =
        if parent?
        then [childId]
        else
          if child?
          then [parentId]
          else [parentId, childId]

      if offendingIds.length is 1
        throw new Error """
          Attempted to link invalid entities #{parentId} -> #{childId}.
          (#{offendingIds[0]} does not exist.)"""
      else
        throw new Error """
          Attempted to link invalid entities #{parentId} -> #{childId}.
          (Neither exists.)"""

  ###
  Mutates an entity in a provided callback.

    scene [Scene] - the invoking `Scene`
    entityId [String] - the id of the entity to be modified
    proc [Function<Entity, Entity>] - procedure which takes in the specified
      `Entity` and returns a modified copy of the `Entity`. this procedure is
      not called if no `Entity` with ID `entityId` exists in this `Scene`.
  ###
  @mutateEntity: (scene, entityId, proc) ->
    entity = Scene.getEntity scene, entityId
    if entity?
    then _.assign {}, scene, entities: (Set.put scene.entities, proc entity)
    else scene


module.exports = Scene