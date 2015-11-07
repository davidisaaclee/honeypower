{createStore} = require 'redux'

k = require '../src/ActionTypes'
sceneReducer = require '../src/reducers/SceneReducer'

Scene = require '../src/model/Scene'
Timeline = require '../src/model/timelines/Timeline'

Entity = require '../src/model/entities/Entity'

Path = require '../src/model/graphics/Path'
Vector2 = require '../src/model/graphics/Vector2'

describe 'Scene:', () ->
  beforeEach () ->
    @empty = createStore sceneReducer

    @path = Path.make (Vector2.make 0, 0), [
      Vector2.make 0, 0
      Vector2.make 1, 1
    ]

    # ooChain null
    #   .let 'kiddo': Entity.make 'kiddo'
    #   .let 'timeline': Timeline.make 'PathTimeline', path
    #   .in (l) -> Scene.with [l.kiddo], [l.timeline]
    #   .let (v) -> 'kiddoEntity': Scene.getEntityByName v, 'kiddo'
    #   .let (v) -> 'timeline': (Scene.getAllTimelines prefilledScene)[0]
    #   .in (l) ->
    #     [Scene.attachEntityToTimeline, l.kiddoEntity.id, l.timeline.id, 0]
    #   .value()

    prefilledScene = Scene.with \
      [Entity.make 'kiddo'],
      [Timeline.make 'PathTimeline', 1, path: @path]

    kiddoEntityId = Entity.getId (Scene.getEntityByName prefilledScene, 'kiddo')
    @timelineId = Timeline.id.get (Scene.getAllTimelines prefilledScene)[0]
    prefilledScene = Scene.mutateTimeline prefilledScene, @timelineId, (tmln) ->
      Timeline.updateMethod.set tmln, Timeline.UpdateMethod.Time
    prefilledScene =
      Scene.attachEntityToTimeline prefilledScene, kiddoEntityId, @timelineId, 0
    @prefilled = createStore sceneReducer, prefilledScene


  it '(loads default state)', () ->
    scene = @empty.getState()
    expect Scene.getAllEntities scene
      .toEqual []
    expect Scene.getAllTimelines scene
      .toEqual []


  # Denotes the passing of time. Can be positive, zero, or negative.
  #
  #   delta: Number
  it 'DeltaTime', () ->
    scene = @prefilled.getState()

    expect Path.pointAt @path, 0.5
      .toEqual Vector2.make 0.5, 0.5

    expect Scene.getEntityByName scene, 'kiddo'
      .toBeDefined()
    expect Entity.getPosition (Scene.getEntityByName scene, 'kiddo')
      .toEqual Vector2.make 0, 0

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: 0.5

    scene = @prefilled.getState()
    kiddo = Scene.getEntityByName scene, 'kiddo'
    expect Entity.getProgressForTimeline kiddo, @timelineId
      .toEqual 0.5
    expect Entity.getPosition kiddo
      .toEqual Vector2.make 0.5, 0.5

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: -0.2

    scene = @prefilled.getState()
    expect Entity.getPosition (Scene.getEntityByName scene, 'kiddo')
      .toEqual Vector2.make 0.3, 0.3

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: 2

    scene = @prefilled.getState()
    kiddo = Scene.getEntityByName scene, 'kiddo'
    expect Entity.getProgressForTimeline kiddo, @timelineId
      .toBe 1
    expect Entity.getPosition kiddo
      .toEqual Vector2.make 1, 1

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: -0.1

    scene = @prefilled.getState()
    kiddo = Scene.getEntityByName scene, 'kiddo'
    expect Entity.getProgressForTimeline kiddo, @timelineId
      .toBe 0.9
    expect Entity.getPosition kiddo
      .toEqual Vector2.make 0.9, 0.9
