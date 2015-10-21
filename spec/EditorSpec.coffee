{createStore} = require 'redux'
k = require '../src/ActionTypes'
editorReducer = require '../src/reducers/EditorReducer'
Scene = require '../src/model/Scene'
Editor = require '../src/model/Editor'
Entity = require '../src/model/entities/Entity'
Vector2 = require '../src/model/graphics/Vector2'
Transform = require '../src/model/graphics/Transform'

describe 'Editor', () ->
  beforeEach () ->
    initialState = Editor.empty
    birdo = Entity.make 'birdo'
    kiddo = Entity.make 'kiddo'
    initialState = Editor.addPrototype initialState, 'birdo', birdo
    initialState = Editor.addPrototype initialState, 'kiddo', kiddo

    @store = createStore editorReducer, initialState


  it 'loads default state', () ->
    store = createStore editorReducer
    editor = store.getState()
    expect (Scene.getAllEntities editor.scene)
      .toEqual []


  it 'can stamp prototypes', () ->
    expect Entity.getPosition (Editor.getPrototype @store.getState(), 'birdo')
      .toEqual (Vector2.make 0, 0)
    expect (Scene.getAllEntities @store.getState().scene)
      .toEqual []

    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        transform: Transform.withPosition (Vector2.make 10, 10)

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 1
    expect Entity.getName (Scene.getAllEntities @store.getState().scene)[0]
      .toEqual 'birdo'
    expect Entity.getPosition (Scene.getAllEntities @store.getState().scene)[0]
      .toEqual (Vector2.make 10, 10)
    expect Entity.getPosition (Editor.getPrototype @store.getState(), 'birdo')
      .toEqual (Vector2.make 0, 0)


  xit 'can add entities', () ->
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