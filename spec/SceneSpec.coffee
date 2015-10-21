{createStore} = require 'redux'
k = require '../src/ActionTypes'
sceneReducer = require '../src/reducers/SceneReducer'
Scene = require '../src/model/Scene'
Entity = require '../src/model/entities/Entity'

describe 'Scene', () ->
  beforeEach () ->
    @store = createStore sceneReducer

  it 'loads default state', () ->
    scene = @store.getState()