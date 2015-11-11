_ = require 'lodash'
Lens = require 'lens'
Model = require './Model'
Entity = require './entities/Entity'
Timeline = require './timelines/Timeline'
TimelinesTable = require './timelines/TimelinesTable'
Set = require '../util/Set'

clamp = require '../util/clamp'

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
      (Set.withHashFunction Entity.id.get),
      (Set.withHashFunction Timeline.id.get)


  ### Lenses ###

  @entitySet: Lens.fromPath 'entities'

  @allEntities: Lens.compose Scene.entitySet, Set.asArray

  @entity: do ->
    composed = Lens.compose Scene.entitySet, Set.element
    new Lens \
      (scene, id) -> composed.get scene, [], [id],
      (scene, id, v) -> composed.set scene, [], [id], v

  @entityByName: new Lens \
    (scene, name) -> Set.find (Scene.entitySet.get scene), name: name,
    (scene, name, v) ->
      id =
        Entity.id.get (Set.find (Scene.entitySet.get scene), {name: name})
      Scene.entity.over scene, id, (e) -> v

  @timelineSet: Lens.fromPath 'timelines'

  @allTimelines: Lens.compose Scene.timelineSet, Set.asArray

  @timeline: do ->
    composed = Lens.compose Scene.timelineSet, Set.element
    new Lens \
      (scene, id) -> composed.get scene, [], [id],
      (scene, id, v) -> composed.set scene, [], [id], v



  # Access

  @getAllEntityIds: (scene) -> Set.keys scene.entities


  # Mutation

  @addEntity: (scene, entity) ->
    _.assign {}, scene,
      entities: Set.put scene.entities, entity

  @removeEntity: (scene, entityId) ->
    _.assign {}, scene,
      entities: Set.remove scene.entities, (Set.get scene.entities, entityId)

  @linkEntitiesById: (scene, parentId, childId) ->
    parent = Scene.entity.get scene, parentId
    child = Scene.entity.get scene, childId

    if parent? and child?
      newScene = scene
      newScene = Scene.entity.over newScene, parent.id, (e) ->
        Entity.child.set e, child
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


  @addTimeline: (scene, timeline) ->
    _.assign {}, scene,
      timelines: Set.put scene.timelines, timeline


  @removeTimelineById: (scene, timelineId) ->
    toRemove = Set.get scene.timelines, timelineId
    _.assign {}, scene,
      timelines: Set.remove scene.timelines, toRemove


  @attachEntityToTimeline: (scene, entityId, timelineId, progress = 0, stackPosition = 0) ->
    entity = Scene.entity.get scene, entityId
    timeline = Scene.timeline.get scene, timelineId

    if entity? and timeline?
      Scene.entity.over scene, entityId, (e) ->
        Entity.insertTimeline e, timelineId, progress, stackPosition
    else scene


  @detachEntityFromTimelineAtIndex: (scene, entityId, timelineIdx) ->
    Scene.entity.over scene, entityId, (e) ->
      Entity.removeTimeline e, timelineIdx


  @updateEntityData: (scene, entityId) ->
    Scene.entity.over scene, entityId, (entity) ->
      Scene.Entities.computeEntityData scene, entity


  @progressTimeline: (scene, timelineId, delta) ->
    timelineObj = Scene.timeline.get scene, timelineId
    scaledDelta = delta / Timeline.length.get timelineObj

    # flipped version for easy reduction
    progressEntity = (s, eId) -> Scene.entity.over s, eId, (e) ->
      currentProgress = Entity.progressForTimeline.get e, timelineId
      newProgress = clamp 0, 1, (currentProgress + scaledDelta)

      Entity.progressForTimeline.set e, timelineId, newProgress

    affectedEntityIds =
      Scene.allEntities.get scene
        .filter (entity) -> Entity.isAttachedToTimeline entity, timelineId
        .map (entity) -> Entity.id.get entity

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
        Entity.computedData.set ent,
          Entity.timelineStack.get ent
            .map (timelineId) ->
              timeline = Scene.timeline.get scene, timelineId
              progress = Entity.progressForTimeline.get entity, timelineId
              return (d) -> TimelinesTable.mapping timeline, progress, d
            .reduce ((data, mutator) -> mutator data), (Entity.localData.get ent)

      if arguments.length is 1
      then ctx
      else ctx.apply null, _.tail arguments

    mutateLocalData: (scene, entity, mutator) ->
      ctx = (ent, mutator) ->
        Scene.Entities.computeEntityData scene,
          Entity.localData.over ent, mutator

      if arguments.length is 1
      then ctx
      else ctx.apply null, _.tail arguments

module.exports = Scene