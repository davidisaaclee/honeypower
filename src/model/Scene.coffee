_ = require 'lodash'
u = require 'updeep'
{createStore} = require 'redux'
Model = require './Model'
Entity = require './entities/Entity'
Timeline = require './timelines/Timeline'
TimelinesTable = require './timelines/TimelinesTable'
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

  @with: (entitiesArray = [], timelineArray = []) ->
    Scene.make \
      (entitiesArray.reduce Set.put, Set.withHashProperty 'id'),
      (timelineArray.reduce Set.put, Set.withHashProperty 'id')

  @empty: Object.freeze \
    Scene.make \
      (Set.withHashFunction Entity.getId),
      (Set.withHashFunction Timeline.id.get)


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

  @getTimeline: @getTimelineById

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


  @attachEntityToTimeline: (scene, entityId, timelineId, progress = 0, stackPosition = 0) ->
    entity = Scene.getEntity scene, entityId
    timeline = Scene.getTimeline scene, timelineId

    if entity? and timeline?
      Scene.mutateEntity scene, entityId, (e) ->
        Entity.insertTimeline e, timelineId, progress, stackPosition
    else scene


  @detachEntityFromTimelineAtIndex: (scene, entityId, timelineIdx) ->
    Scene.mutateEntity scene, entityId, (e) ->
      Entity.removeTimeline e, timelineIdx


  @updateEntityData: (scene, entityId) ->
    Scene.mutateEntity scene, entityId, (entity) ->
      Scene.Entities.computeEntityData scene, entity


  @mutateTimeline: (scene, timelineId, proc) ->
    timeline = Scene.getTimelineById scene, timelineId
    if timeline?
    then _.assign {}, scene, timelines: (Set.put scene.timelines, proc timeline)
    else scene


  @progressTimeline: (scene, timelineId, delta) ->
    timelineObj = Scene.getTimeline scene, timelineId
    scaledDelta = delta / Timeline.length.get timelineObj

    # flipped version for easy reduction
    progressEntity = (s, eId) -> Scene.mutateEntity s, eId, (e) ->
      currentProgress =
        Entity.getProgressForTimeline e, timelineId
      d = switch
        when (currentProgress + scaledDelta) > 1
          1 - currentProgress
        when (currentProgress + scaledDelta) < 0
          0 - currentProgress
        else
          scaledDelta

      Entity.progressTimeline e, timelineId, d

    affectedEntityIds =
      Scene.getAllEntities scene
        .filter (entity) -> Entity.isAttachedToTimeline entity, timelineId
        .map (entity) -> Entity.getId entity

    sceneWithUpdatedProgress = affectedEntityIds.reduce progressEntity, scene
    affectedEntityIds.reduce Scene.updateEntityData, sceneWithUpdatedProgress


  ###
  Entity methods

  These functions operate on and return entities, but necessitate knowledge of
    the scene. They are thus all "semi-curried" - given a single argument, the
    scene context, they each produce a function which awaits the rest of the
    arguments, and operates over the provided scene as context.
  (Implied with this is that these functions do not mutate anything outside of
    the specified entity.)

  fn(scene, a, b, c) == fn(scene)(a, b, c)
  ###

  @Entities:
    computeEntityData: (scene, entity) ->
      ctx = (ent) ->
        Entity.setComputedData ent,
          Entity.getTimelineStack ent
            .map (timelineId) ->
              timeline = Scene.getTimeline scene, timelineId
              progress = Entity.getProgressForTimeline entity, timelineId
              return (d) -> TimelinesTable.mapping timeline, progress, d
            .reduce ((data, mutator) -> mutator data), (Entity.getLocalData ent)

      if arguments.length is 1
      then ctx
      else ctx.apply null, _.tail arguments

    mutateLocalData: (scene, entity, mutator) ->
      ctx = (ent, mutator) ->
        ent = Entity.setLocalData ent, (mutator Entity.getLocalData ent)
        ent = Scene.Entities.computeEntityData scene, ent

      if arguments.length is 1
      then ctx
      else ctx.apply null, _.tail arguments

module.exports = Scene