_ = require 'lodash'
updeep = require 'updeep'
k = require '../ActionTypes'

mapAssign = require '../util/mapAssign'
addChildReducers = require '../util/addChildReducers'

Scene = require '../model/Scene'
Entity = require '../model/entities/Entity'
Set = require '../util/Set'

sceneReducer = require './SceneReducer'

defaultState =
  scene: Scene.empty

###
Reducer for all actions contained within entities.
###
reducer = (state = defaultState, action) ->
  switch action.type
    when k.AddEntity
      {name, transform, children} = action.data

      newEntity = Entity.make name, transform, children
      _.assign {}, state,
        scene: Scene.addEntity state.scene, newEntity

    else state


module.exports = addChildReducers reducer,
  'scene': sceneReducer