{createStore} = require 'redux'
k = require '../src/ActionTypes'
editorReducer = require '../src/reducers/EditorReducer'
Scene = require '../src/model/Scene'
Editor = require '../src/model/Editor'
Kit = require '../src/model/Kit'
Entity = require '../src/model/entities/Entity'
Vector2 = require '../src/model/graphics/Vector2'
Transform = require '../src/model/graphics/Transform'

describe 'Editor actions:', () ->
  beforeEach () ->
    birdo = Entity.make 'birdo'
    kiddo = Entity.make 'kiddo'

    birdoKiddoKit = Kit.with 'birdoKiddo', [birdo, kiddo], [], []

    initialState = Editor.withKits [birdoKiddoKit]

    @store = createStore editorReducer, initialState


  it '(load initial state)', () ->
    store = createStore editorReducer
    editor = store.getState()
    expect (Scene.getAllEntities editor.scene)
      .toEqual []

  it '(kit access)', () ->
    expect (Editor.getPrototype @store.getState(), 'birdo')
      .toBeDefined()


  it 'StampPrototype (onto scene)', () ->
    expect Entity.getPosition (Editor.getPrototype @store.getState(), 'birdo')
      .toEqual (Vector2.make 0, 0)
    expect (Scene.getAllEntities @store.getState().scene)
      .toEqual []

    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        transform: Transform.withPosition (Vector2.make 10, 10)

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 1
    expect Entity.getName (Scene.getAllEntities @store.getState().scene)[0]
      .toEqual 'birdo'
    expect Entity.getPosition (Scene.getAllEntities @store.getState().scene)[0]
      .toEqual (Vector2.make 10, 10)
    expect Entity.getPosition (Editor.getPrototype @store.getState(), 'birdo')
      .toEqual (Vector2.make 0, 0)


  xit 'RemoveEntity', () ->
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        transform: Transform.withPosition (Vector2.make 10, 10)

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 1
    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdo'

    @store.dispatch
      type: k.RemoveEntity
      data:
        entity: birdoInstance.id

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 0


  # Transform an `Entity`'s static transform.
  #
  #  entity: String
  #  transform: Transform
  xit 'TransformEntity', () ->
    initialPosition = Vector2.make 10, 10
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        transform: Transform.withPosition initialPosition

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdo'
    expect Entity.getPosition birdoInstance
      .toEqual initialPosition
    expect Entity.getRotation birdoInstance
      .toEqual 0
    expect Entity.getScale birdoInstance
      .toEqual (Vector2.make 1, 1)

    translationAmount = Vector2.make 2, 2

    @store.dispatch
      type: k.TransformEntity
      data:
        entity: birdoInstance.id
        transform: Transform.withPosition translationAmount

    expect Entity.getPosition birdoInstance
      .toEqual (Vector2.add initialPosition, translationAmount)
    expect Entity.getRotation birdoInstance
      .toEqual 0
    expect Entity.getScale birdoInstance
      .toEqual (Vector2.make 1, 1)

    xform = Transform.make \
      translationAmount,
      (Math.PI / 2),
      (Vector2.make 2, 1)
    @store.dispatch
      type: k.TransformEntity
      data:
        entity: birdoInstance.id
        transform: xform

    expect Entity.getPosition birdoInstance
      .toEqual (Vector2.add initialPosition, (Vector2.scale translationAmount, 2))
    expect Entity.getRotation birdoInstance
      .toEqual (Math.PI / 2)
    expect Entity.getScale birdoInstance
      .toEqual (Vector2.make 2, 1)

    @store.dispatch
      type: k.TransformEntity
      data:
        entity: birdoInstance.id
        transform: Transform.withScale (Vector2.make 3, 2)

    expect Entity.getPosition birdoInstance
      .toEqual (Vector2.add initialPosition, (Vector2.scale translationAmount, 2))
    expect Entity.getRotation birdoInstance
      .toEqual (Math.PI / 2)
    expect Entity.getScale birdoInstance
      .toEqual (Vector2.make 6, 2)






  # Pending specs

  xit 'StampPrototype (onto entities)', () ->
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        transform: Transform.withPosition (Vector2.make 10, 10)

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdo'

    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'kiddo'
        onto: birdoInstance.id
        transform: Transform.withPosition (Vector2.make 0, 0)


  xit 'LinkEntities', () ->
    assertPure (() => @store.getState()), () =>
      @store.dispatch
        type: k.StampPrototype
        data:
          proto: 'birdo'
          transform: Transform.withPosition (Vector2.make 10, 10)

      @store.dispatch
        type: k.StampPrototype
        data:
          proto: 'kiddo'
          transform: Transform.withPosition (Vector2.make 10, 10)

      birdoInstance_ = Scene.getEntityByName @store.getState().scene, 'birdo'
      kiddoInstance_ = Scene.getEntityByName @store.getState().scene, 'kiddo'

      @store.dispatch
        type: k.LinkEntities
        data:
          parent: birdoInstance_.id
          child: kiddoInstance_.id

      scene = @store.getState().scene

    birdoInstance = Scene.getEntityByName scene, 'birdo'
    expect birdoInstance
      .toBeDefined()

    # Names of children entities:
    #   Uncertain about this; and names are not very important anyways.
    #
    # kiddoInstance = Scene.getEntityByName scene, 'kiddo'
    # expect kiddoInstance
    #   .toBeDefined()

    expect Entity.getChild birdoInstance
      .toBeDefined()
    expect Entity.getChild birdoInstance
      .toMatchObject
        name: 'kiddo'
    expect Entity.getChild (Entity.getChild birdoInstance)
      .toBeUndefined()


  # TODO: this has a bunch of new specs about registering kits
  xit 'RequestEntityEditor', () ->
    eddy = Entity.make 'eddy'
    eddy.customEditor = 'bearInspector'

    bearCentricKit = Kit.make
      prototypes: ['eddy']
      inspectors: ['bearInspector']
      physics: []

    initialEditor = Editor.make Scene.empty, [bearCentricKit]
    store = createStore editorReducer, initialEditor

    store.dispatch
      type: k.StampPrototype
      data:
        proto: 'eddy'
        name: 'eddy jr'
        transform: Transform.withPosition (Vector2.make 10, 10)

    eddyInstance = Scene.getEntityByName scene, 'eddy jr'

    @store.dispatch
      type: k.RequestEntityEditor
      data:
        entity: eddyInstance.id

    expect (_.head @store.getState().activeInspectors).id
      .toBe 'bearInspector'



  # xit 'can add entities', () ->
  #   @store.dispatch
  #     type: k.AddEntity
  #     data:
  #       name: 'kiddo'

  #   scene = @store.getState().scene

  #   expect (Scene.getAllEntities scene).length
  #     .toBe 1
  #   expect (Scene.getEntityByName scene, 'kiddo')
  #     .toBeDefined()

  #   @store.dispatch
  #     type: k.AddEntity,
  #     data:
  #       name: 'birdo'

  #   scene = @store.getState().scene

  #   expect (Scene.getAllEntities scene).length
  #     .toBe 2
  #   expect (Scene.getEntityByName scene, 'kiddo')
  #     .toBeDefined()
  #   expect (Scene.getEntityByName scene, 'birdo')
  #     .toBeDefined()