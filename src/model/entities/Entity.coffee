_ = require 'lodash'

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

    return (name = null, transform = Transform.default, child = null, proto) ->
      _.assign (new Entity()),
        id: _nextId()
        name: name
        transform: transform
        child: child


  # Access

  @getId: (entity) -> entity.id

  @getName: (entity) -> entity.name

  @getChild: (entity) -> entity.child

  @getPosition: (entity) -> Transform.getPosition entity.transform

  @getRotation: (entity) -> Transform.getRotation entity.transform

  @getScale: (entity) -> Transform.getScale entity.transform

  @getAllAttachedTimelines: (entity) -> Set.asArray entity.attachedTimelines


  # Mutation

  # entity [Entity] - to be parent
  # child [Entity]
  @setChild: (entity, child) ->
    _.assign {}, entity,
      child: child

  @removeChild: (entity) ->
    _.assign {}, entity,
      child: null

  @addTimeline: (entity, timelineId, progress = 0) ->
    newAttachedTimelines = Set.put entity.attachedTimelines,
      timeline: timelineId
      progress: progress
    _.assign {}, entity,
      attachedTimelines: newAttachedTimelines

  @removeTimeline: (entity, timelineId) ->
    _.assign {}, entity,
      attachedTimelines: Set.removeByHash entity.attachedTimelines, timelineId

  @transform: (entity, {translate, rotate, scale}) ->
    if translate?
      Entity.translate entity, translate
    if rotate?
      Entity.rotate entity, rotate
    if scale?
      Entity.scale entity, scale

  @translate: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.translate entity.transform, amount

  @rotate: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.rotate entity.transform, amount

  @scale: (entity, amount) ->
    _.assign {}, entity,
      transform: Transform.scale entity.transform, amount

module.exports = Entity