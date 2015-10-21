_ = require 'lodash'

Model = require '../Model'
Transform = require '../graphics/Transform'

###
Entities are hierarchical graphical objects.

Entity ::=
  id: String
  name: String | null
  transform: Transform
  children: [Entity]
###
class Entity extends Model
  @make: do ->
    _spawnCount = 0
    _nextId = () -> "entity-#{_spawnCount++}"

    return (name = null, transform = Transform.default, children = []) ->
      _.assign (new Entity()),
        id: _nextId()
        name: name
        transform: transform
        children: children


  # Access

  @getId: (entity) -> entity.id

  @getName: (entity) -> entity.name

  @getChildren: (entity) -> entity.children

  @getPosition: (entity) -> Transform.getPosition entity.transform

  @getRotation: (entity) -> Transform.getRotation entity.transform

  @getScale: (entity) -> Transform.getScale entity.transform


  # Mutation

  @addChild: (entity, child) ->
    _.assign {}, entity,
      children: [entity.children..., child]

  @removeChild: (entity, childId) ->
    idx = _.findIndex (Entity.getChildren entity), (child) -> child.id is childId
    if idx isnt -1
    then _.assign {}, entity,
        children: [ (entity.children.splice 0, idx)...,
                    (entity.children.splice (idx + 1))... ]
    else entity

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