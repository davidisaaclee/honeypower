_ = require 'lodash'
updeep = require 'updeep'
k = require '../ActionTypes'
mapAssign = require '../util/mapAssign'
addChildReducers = require '../util/addChildReducers'

Entity = require '../model/entities/Entity'
Set = require '../util/Set'

defaultState = Set.withHashFunction (entity) -> entity.id

###
Reducer for all actions contained within entities.
###
reducer = (state = defaultState, action) ->
  return state
  # switch action.type
  #   when k.TransformEntity
  #     {entityId, translate, rotate, scale} = action.data
  #     if Set.contains state, entityId
  #       entity = Set.get state, entityId
  #       newEntity = Entity.transform entity,
  #         translate: translate
  #         rotate: rotate
  #         scale: scale

  #       Set.put state, newEntity

  #   else state


module.exports = reducer