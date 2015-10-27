_ = require 'lodash'
u = require 'updeep'
{createStore} = require 'redux'
darko = require 'darko'
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
  @make: (entities, timelines) ->
    _.assign (new Scene()),
      entities: entities
      timelines: timelines
      darko: null

  @with: (entitiesArray = [], timelineArray = []) ->
    Scene.make \
      (entitiesArray.reduce Set.put, Set.withHashProperty 'id'),
      (timelineArray.reduce Set.put, Set.withHashProperty 'id')

  @empty: Object.freeze \
    Scene.make \
      (Set.withHashProperty 'id'),
      (Set.withHashProperty 'id')


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


  @getTimelineById: (scene, timelineId) ->
    Set.get scene.timelines, timelineId

  @getAllTimelines: (scene) ->
    Set.asArray scene.timelines


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
      # this is just being too committed to error messages, ignore
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


  @addTimeline: (scene, timeline) ->
    _.assign {}, scene,
      timelines: Set.put scene.timelines, timeline


  @removeTimelineById: (scene, timelineId) ->
    toRemove = Set.get scene.timelines, timelineId
    _.assign {}, scene,
      timelines: Set.remove scene.timelines, toRemove


  @attachEntityToTimeline: (scene, entityId, timelineId, initialProgress = 0) ->
    # TODO


  @mutateTimeline: (scene, timelineId, proc) ->
    timeline = Scene.getTimelineById scene, timelineId
    if timeline?
    then _.assign {}, scene, timelines: (Set.put scene.timelines, proc timeline)
    else scene


module.exports = Scene