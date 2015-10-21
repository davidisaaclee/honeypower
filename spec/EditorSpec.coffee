{createStore} = require 'redux'
k = require '../src/ActionTypes'
editorReducer = require '../src/reducers/EditorReducer'
Scene = require '../src/model/Scene'
Entity = require '../src/model/entities/Entity'

describe 'Editor', () ->
  beforeEach () ->
    @store = createStore editorReducer

  it 'loads default state', () ->
    editor = @store.getState()
    expect (Scene.getAllEntities editor.scene)
      .toEqual []

  it 'can add entities', () ->
    @store.dispatch
      type: k.AddEntity
      data:
        name: 'kiddo'

    scene = @store.getState().scene

    expect (Scene.getAllEntities scene).length
      .toBe 1
    expect (Scene.getEntityByName scene, 'kiddo')
      .toBeDefined()

    @store.dispatch
      type: k.AddEntity,
      data:
        name: 'birdo'

    scene = @store.getState().scene

    expect (Scene.getAllEntities scene).length
      .toBe 2
    expect (Scene.getEntityByName scene, 'kiddo')
      .toBeDefined()
    expect (Scene.getEntityByName scene, 'birdo')
      .toBeDefined()