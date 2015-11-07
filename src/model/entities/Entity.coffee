# TODO: change all attached timelines to IDs
#       make it so entities can be attached to any timeline only once

_ = require 'lodash'
Immutable = require 'immutable'

Set = require '../../util/Set'

Model = require '../Model'
Transform = require '../graphics/Transform'

###
Entities are hierarchical graphical objects.

Entity ::=
  id: String
  name: String | null
  transform: Transform
  child: Entity
###
class Entity extends Model

EntityFunctions =
  make: do ->
    _spawnCount = 0
    _nextId = () -> "entity-#{_spawnCount++}"

    return (name, transform, child, id) ->
      config =
        name: name
        child: child
        id: id

      initialData = _.defaults {},
        {transform: transform},
        {transform: Transform.default}

      fields = _.defaults config,
        id: _nextId()
        child: null
        name: null
        timelines: Immutable.List()
        timelinesData: Immutable.Map()
        localData: initialData
        computedData: initialData


      r = _.assign new Entity(), fields

      return r


  # Access

  getId: (entity) -> entity.id

  getName: (entity) -> entity.name

  getChild: (entity) -> entity.child

  getLocalData: (entity) -> entity.localData

  getComputedData: (entity) -> entity.computedData

  getTimelineStack: (entity) -> entity.timelines.toArray()

  getProgressForTimeline: (entity, timelineId) ->
    (entity.timelinesData.get timelineId).progress

  isAttachedToTimeline: (entity, timelineId) ->
    entity.timelinesData.has timelineId

  getTransform: (entity) ->
    (EntityFunctions.getComputedData entity).transform

  getPosition: (entity) ->
    Transform.getPosition EntityFunctions.getTransform entity

  getRotation: (entity) ->
    Transform.getRotation EntityFunctions.getTransform entity

  getScale: (entity) ->
    Transform.getScale EntityFunctions.getTransform entity


  # Mutation

  # entity [Entity] - to be parent
  # child [Entity]
  setChild: (entity, child) ->
    _.assign {}, entity,
      child: child

  removeChild: (entity) ->
    _.assign {}, entity,
      child: null

  setLocalData: (entity, localData) ->
    _.assign {}, entity,
      localData: localData

  setComputedData: (entity, computedData) ->
    _.assign {}, entity,
      computedData: computedData

  insertTimeline: (entity, timelineId, progress = 0, stackPosition = 0) ->
    _.assign {}, entity,
      timelines: entity.timelines.splice stackPosition, 0, timelineId
      timelinesData: entity.timelinesData.set timelineId,
        progress: progress

  removeTimeline: (entity, timelineIdx) ->
    timelineId = entity.timelines.get timelineIdx
    if timelineId?
      _.assign {}, entity,
        timelines: entity.timelines.delete timelineIdx
        timelinesData: entity.timelinesData.delete timelineId
    else entity

  # Simply updates the `progress` field within `timelinesData` - does not update
  #   `computedData` or respect loop/start/end.
  progressTimeline: (entity, timelineId, delta) ->
    _.assign {}, entity,
      timelinesData: entity.timelinesData.update timelineId, (timelineData) ->
        _.assign {}, timelineData,
          progress: timelineData.progress + delta

  setTransform: (entity, transform) ->
    newLocaldata = _.assign (EntityFunctions.getLocalData entity),
      transform: transform
    EntityFunctions.setLocalData entity, newLocaldata

  transform: (entity, {translate, rotate, scale}) ->
    if translate?
      EntityFunctions.translate entity, translate
    if rotate?
      EntityFunctions.rotate entity, rotate
    if scale?
      EntityFunctions.scale entity, scale

  translate: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.translate (EntityFunctions.getTransform entity), amount

  rotate: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.rotate (EntityFunctions.getTransform entity), amount

  scale: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.scale (EntityFunctions.getTransform entity), amount

module.exports = EntityFunctions