_ = require 'lodash'
updeep = require 'updeep'
{combineReducers} = require 'redux'
k = require '../ActionTypes'



Scene = require '../model/Scene'
Entity = require '../model/entities/Entity'

Set = require '../util/Set'

mapAssign = require '../util/mapAssign'
addChildReducers = require '../util/addChildReducers'

clamp = require '../util/clamp'
wrap = require '../util/wrap'

# entitiesReducer = require './EntityReducer'

defaultState = Scene.empty

reducer = (state = defaultState, action) ->
  state
  # switch action.type
  #   when k.AddEntity
  #     {name, transform, children} = action.data

  #     Scene.addEntity state, (Entity.make name, transform, children)

  #   else state


module.exports = reducer