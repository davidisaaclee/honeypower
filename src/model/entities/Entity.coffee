# TODO: change all attached timelines to IDs
#       make it so entities can be attached to any timeline only once

_ = require 'lodash'
Immutable = require 'immutable'
Lens = require 'lens'

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

      return _.assign new Entity(), fields


  ### Lenses ###

  id: Lens.fromPath 'id'

  name: Lens.fromPath 'name'

  child: Lens.fromPath 'child'

  localData: Lens.fromPath 'localData'

  computedData: Lens.fromPath 'computedData'

  timelineStack: new Lens \
    (entity) -> entity.timelines.toArray(),
    null

  timelineData: new Lens \
    (entity, timelineId) -> entity.timelinesData.get timelineId,
    (entity, timelineId, val) -> _.assign {}, entity,
      timelinesData: entity.timelinesData.set timelineId, val

  progressForTimeline: new Lens \
    (entity, timelineId) -> (entity.timelinesData.get timelineId).progress,
    (entity, timelineId, progress) ->
      EntityFunctions.timelineData.over entity, timelineId, (timelineData) ->
        _.assign {}, timelineData, { progress: progress }

  # transform:
  #   Lens.compose (Lens.fromPath 'computedData'), (Lens.fromPath 'transform')

  # position: Lens.compose EntityFunctions.transform, Transform.position


  # Access

  isAttachedToTimeline: (entity, timelineId) ->
    entity.timelinesData.has timelineId

  # getTransform: (entity) ->
  #   (EntityFunctions.computedData.get entity).transform

  # getPosition: (entity) ->
  #   Transform.getPosition EntityFunctions.transform.get entity

  # getRotation: (entity) ->
  #   Transform.getRotation EntityFunctions.transform.get entity

  # getScale: (entity) ->
  #   Transform.getScale EntityFunctions.transform.get entity


  # Mutation

  removeChild: (entity) -> EntityFunctions.child.set entity, null
    # _.assign {}, entity,
    #   child: null

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
  # progressTimeline: (entity, timelineId, delta) ->
  #   _.assign {}, entity,
  #     timelinesData: entity.timelinesData.update timelineId, (timelineData) ->
  #       _.assign {}, timelineData,
  #         progress: timelineData.progress + delta

  # setTransform: (entity, transform) ->
  #   newLocaldata = _.assign (EntityFunctions.getLocalData entity),
  #     transform: transform
  #   EntityFunctions.setLocalData entity, newLocaldata

  # transform: (entity, {translate, rotate, scale}) ->
  #   if translate?
  #     EntityFunctions.translate entity, translate
  #   if rotate?
  #     EntityFunctions.rotate entity, rotate
  #   if scale?
  #     EntityFunctions.scale entity, scale


  # TODO: these transform functions are not tested

  translateBy: (entity, amount) ->
    EntityFunctions.transform.over entity, (transform) ->
      Transform.translateBy transform, amount
    # _.assign {}, entity,
    #   transform: Transform.translateBy (EntityFunctions.transform.get entity), amount

  rotateBy: (entity, amount) ->
    EntityFunctions.transform.over entity, (transform) ->
      Transform.rotateBy transform, amount
    # _.assign {}, entity,
    #   transform: Transform.rotateBy (EntityFunctions.transform.get entity), amount

  scaleBy: (entity, amount) ->
    EntityFunctions.transform.over entity, (transform) ->
      Transform.scaleBy transform, amount
    _.assign {}, entity,
      transform: Transform.scaleBy (EntityFunctions.transform.get entity), amount



# Self-referential properties

_.assign EntityFunctions,
  transform:
    Lens.compose EntityFunctions.computedData, Lens.fromPath 'transform'

_.assign EntityFunctions,
  position: Lens.compose EntityFunctions.transform, Transform.position
  rotation: Lens.compose EntityFunctions.transform, Transform.rotation
  scale: Lens.compose EntityFunctions.transform, Transform.scale


module.exports = EntityFunctions