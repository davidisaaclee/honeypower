_ = require 'lodash'
updeep = require 'updeep'
k = require '../ActionTypes'

mapAssign = require '../util/mapAssign'
addChildReducers = require '../util/addChildReducers'

Scene = require '../model/Scene'
Editor = require '../model/Editor'
Entity = require '../model/entities/Entity'
Transform = require '../model/graphics/Transform'
Set = require '../util/Set'

sceneReducer = require './SceneReducer'

defaultState = Editor.empty


###
Reducer for all actions contained within entities.
###
reducer = (state = defaultState, action) ->
  switch action.type
    # when k.AddEntity
    #   {name, transform, children} = action.data

    #   newEntity = Entity.make name, transform, children
    #   _.assign {}, state,
    #     scene: Scene.addEntity state.scene, newEntity


    when k.RemoveEntity
      {entity} = action.data
      _.assign {}, state, scene: (Scene.removeEntity state.scene, entity)


    when k.StampPrototype
      {proto, onto, name, transform} = action.data

      stamp = Editor.stampPrototype state, proto
      stamp = _.assign stamp,
        transform: transform
        name: name

      newScene = Scene.addEntity state.scene, stamp

      if onto?
        parentObj = Scene.getEntity state.scene, onto
        newScene = Scene.linkEntitiesById newScene, parentObj.id, stamp.id

      _.assign {}, state,
        scene: newScene


    when k.TransformEntity
      {entity, transform} = action.data

      _.assign {}, state,
        scene: Scene.mutateEntity state.scene, entity, (e) ->
          _.assign {}, e,
            transform: Transform.applyTransform e.transform, transform


    when k.LinkEntities
      {parent, child} = action.data
      r = _.assign {}, state,
        scene: Scene.linkEntitiesById state.scene, parent, child

      # if parentObj? and childObj?
      #   # remove from base level?
      #   newScene = Scene.removeEntity state.scene, childObj.id
      #   newScene = Scene.mutateEntity state.scene, parent, (e) ->
      #     Entity.setChild e, childObj
      #   _.assign {}, state,
      #     scene: newScene
      # else state


    else state


module.exports = addChildReducers reducer,
  'scene': sceneReducer