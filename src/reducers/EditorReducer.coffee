_ = require 'lodash'
updeep = require 'updeep'
k = require '../ActionTypes'

mapAssign = require '../util/mapAssign'
addChildReducers = require '../util/addChildReducers'

Scene = require '../model/Scene'
Editor = require '../model/Editor'
Timeline = require '../model/timelines/Timeline'
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
    when k.RemoveEntity
      {entity} = action.data
      Editor.scene.over state, (scene) ->
        Scene.removeEntity scene, entity


    when k.StampPrototype
      {id, proto, onto, name, transform} = action.data


      Editor.scene.over state, (scene) ->
        stamp = Editor.stampPrototype state, proto, transform, name, id
        newScene = Scene.addEntity scene, stamp

        if onto?
          parentObj = Scene.getEntity scene, onto
          newScene = Scene.linkEntitiesById newScene, parentObj.id, stamp.id

        return newScene


    when k.TransformEntity
      {entity, transform} = action.data


      Editor.scene.over state, (scene) ->
        Scene.mutateEntity scene, entity, (e) ->
          Scene.Entities.mutateLocalData scene, e, (data) ->
            _.assign {}, data,
              transform:
                Transform.applyTransform data.transform, transform


    when k.LinkEntities
      {parent, child} = action.data
      Editor.scene.over state, (scene) ->
        Scene.linkEntitiesById scene, parent, child


    when k.RegisterTimeline
      {id, length, type, data} = _.defaults action.data,
        length: 1
      timeline = Timeline.make type, length, data, id
      Editor.scene.over state, (scene) ->
        Scene.addTimeline scene, timeline


    # Attach a timeline to an entity.
    #   timeline: String
    #   entity: String
    #   [progress: Float]     # initial progress; defaults to 0
    #   [stackPosition: Int]  # position in timeline stack; defaults to 0 (top)
    when k.AttachTimeline
      {timeline, entity, progress, stackPosition} = _.defaults action.data,
        progress: 0
        stackPosition: 0

      Editor.scene.over state, (scene) ->
        Scene.attachEntityToTimeline scene,
          entity, timeline, progress, stackPosition


    # Detach a timeline from an entity.
    #   timelineIndex: Int     # the index of the timeline in the entity's timeline stack
    #   entity: String
    when k.DetachTimeline
      {timelineIndex, entity} = action.data

      Editor.scene.over state, (scene) ->
        Scene.detachEntityFromTimelineAtIndex scene, entity, timelineIndex

    else state


module.exports = addChildReducers reducer,
  'scene': sceneReducer