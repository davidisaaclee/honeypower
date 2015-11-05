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
  @make: do ->
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

  @getId: (entity) -> entity.id

  @getName: (entity) -> entity.name

  @getChild: (entity) -> entity.child

  @getLocalData: (entity) -> entity.localData

  @getComputedData: (entity) -> entity.computedData

  @getTransform: (entity) -> (Entity.getComputedData entity).transform

  @getPosition: (entity) -> Transform.getPosition Entity.getTransform entity

  @getRotation: (entity) -> Transform.getRotation Entity.getTransform entity

  @getScale: (entity) -> Transform.getScale Entity.getTransform entity

  @getTimelineStack: (entity) -> entity.timelines.toArray()

  @getProgressForTimeline: (entity, timelineId) ->
    entity.timelinesData.get timelineId


  # Mutation

  # entity [Entity] - to be parent
  # child [Entity]
  @setChild: (entity, child) ->
    _.assign {}, entity,
      child: child

  @removeChild: (entity) ->
    _.assign {}, entity,
      child: null

  @setLocalData: (entity, localData) ->
    _.assign {}, entity,
      localData: localData

  @setComputedData: (entity, computedData) ->
    _.assign {}, entity,
      computedData: computedData

  @insertTimeline: (entity, timelineId, progress = 0, stackPosition = 0) ->
    _.assign {}, entity,
      timelines: entity.timelines.splice stackPosition, 0, timelineId
      timelinesData: entity.timelinesData.set timelineId, progress

  @removeTimeline: (entity, timelineIdx) ->
    timelineId = entity.timelines.get timelineIdx
    if timelineId?
      _.assign {}, entity,
        timelines: entity.timelines.delete timelineIdx
        timelinesData: entity.timelinesData.delete timelineId
    else entity

  @setTransform: (entity, transform) ->
    newLocaldata = _.assign (Entity.getLocalData entity),
      transform: transform
    Entity.setLocalData entity, newLocaldata

  @transform: (entity, {translate, rotate, scale}) ->
    if translate?
      Entity.translate entity, translate
    if rotate?
      Entity.rotate entity, rotate
    if scale?
      Entity.scale entity, scale

  @translate: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.translate (Entity.getTransform entity), amount

  @rotate: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.rotate (Entity.getTransform entity), amount

  @scale: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.scale (Entity.getTransform entity), amount

module.exports = Entity