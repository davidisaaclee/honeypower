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

  xit 'can add entities', () ->
    @store.dispatch
      type: k.AddEntity
      data:
        name: 'kiddo'

    scene = @store.getState()

    expect (Scene.getAllEntities scene).length
      .toBe 1
    expect (Scene.getEntityByName scene, 'kiddo')
      .toBeDefined()

    @store.dispatch
      type: k.AddEntity,
      data:
        name: 'birdo'

    scene = @store.getState()

    expect (Scene.getAllEntities scene).length
      .toBe 2
    expect (Scene.getEntityByName scene, 'kiddo')
      .toBeDefined()
    expect (Scene.getEntityByName scene, 'birdo')
      .toBeDefined()