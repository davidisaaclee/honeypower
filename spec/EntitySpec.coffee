{createStore} = require 'redux'
k = require '../src/ActionTypes'
sceneReducer = require '../src/reducers/SceneReducer'
Entity = require '../src/model/entities/Entity'
Scene = require '../src/model/Scene'
Set = require '../src/util/Set'


describe 'Entities', () ->
  beforeEach () ->
    initialScene = Scene.empty
    initialScene = Scene.addEntity initialScene, Entity.make 'birdo'
    initialScene = Scene.addEntity initialScene, Entity.make 'kiddo'
    @store = createStore sceneReducer, initialScene

    @getEntities = () => @store.getState().entities

    @birdoId = Entity.id.get (Scene.getEntityByName @store.getState(), 'birdo')
    @kiddoId = Entity.id.get (Scene.getEntityByName @store.getState(), 'kiddo')


  it 'loads default state', () ->
    @emptyStore = createStore sceneReducer
    entities = @emptyStore.getState().entities

    expect Set.count entities
      .toEqual 0
