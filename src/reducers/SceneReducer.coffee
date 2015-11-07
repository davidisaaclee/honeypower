_ = require 'lodash'
updeep = require 'updeep'
{combineReducers} = require 'redux'
k = require '../ActionTypes'

Scene = require '../model/Scene'
Entity = require '../model/entities/Entity'
Timeline = require '../model/timelines/Timeline'

Set = require '../util/Set'

mapAssign = require '../util/mapAssign'
addChildReducers = require '../util/addChildReducers'

clamp = require '../util/clamp'
wrap = require '../util/wrap'

# entitiesReducer = require './EntityReducer'

defaultScene = Scene.empty

reducer = (scene = defaultScene, action) ->
  switch action.type
    when k.DeltaTime
      {delta} = action.data

      progress = (s, id) ->
        Scene.progressTimeline s, id, delta

      Scene.getAllTimelines scene
        .filter (tl) ->
          (Timeline.updateMethod.get tl) is Timeline.UpdateMethod.Time
        .map (tl) -> Timeline.id.get tl
        .reduce progress, scene

    else scene


module.exports = reducer