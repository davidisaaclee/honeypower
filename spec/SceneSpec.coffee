{createStore} = require 'redux'

k = require '../src/ActionTypes'
sceneReducer = require '../src/reducers/SceneReducer'

Scene = require '../src/model/Scene'
Timeline = require '../src/model/timelines/Timeline'
PathTimeline = require '../src/model/timelines/PathTimeline'

Entity = require '../src/model/entities/Entity'

Path = require '../src/model/graphics/Path'
Vector2 = require '../src/model/graphics/Vector2'

ooChain = require '../src/util/ooChain'

describe 'Scene:', () ->
  beforeEach () ->
    @empty = createStore sceneReducer

    @path = Path.make (Vector2.make 0, 0), [
      Vector2.make 0, 0
      Vector2.make 1, 1
    ]

    prefilledScene = ooChain null
      .let 'kiddo': Entity.make 'kiddo'
      .let 'timeline': Timeline.make 'PathTimeline', 1, path: @path
      .in (v, l) -> Scene.with [l.kiddo], [l.timeline]
      .let (v) -> 'kiddoEntity': Scene.entityByName.get v, 'kiddo'
      .let (v) -> 'timeline': (Scene.allTimelines.get v)[0]
      .in (v, l) ->
        Scene.timeline.over v, l.timeline.id, (tmln) ->
          Timeline.updateMethod.set tmln, Timeline.UpdateMethod.Time
      .in (v, l) ->
        Scene.attachEntityToTimeline v, l.kiddoEntity.id, l.timeline.id, 0
      .value()

    @timelineId = Timeline.id.get (Scene.allTimelines.get prefilledScene)[0]

    @prefilled = createStore sceneReducer, prefilledScene


  it '(loads default state)', () ->
    scene = @empty.getState()
    expect Scene.allEntities.get scene
      .toEqual []
    expect Scene.allTimelines.get scene
      .toEqual []


  # Denotes the passing of time. Can be positive, zero, or negative.
  #
  #   delta: Number
  it 'DeltaTime', () ->
    scene = @prefilled.getState()

    expect Path.pointAt @path, 0.5
      .toEqual Vector2.make 0.5, 0.5

    expect Scene.entityByName.get scene, 'kiddo'
      .toBeDefined()
    expect Entity.position.get (Scene.entityByName.get scene, 'kiddo')
      .toEqual Vector2.make 0, 0

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: 0.5

    scene = @prefilled.getState()
    kiddo = Scene.entityByName.get scene, 'kiddo'
    expect Entity.progressForTimeline.get kiddo, @timelineId
      .toEqual 0.5
    expect Entity.position.get kiddo
      .toEqual Vector2.make 0.5, 0.5

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: -0.2

    scene = @prefilled.getState()
    expect Entity.position.get (Scene.entityByName.get scene, 'kiddo')
      .toEqual Vector2.make 0.3, 0.3

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: 2

    scene = @prefilled.getState()
    kiddo = Scene.entityByName.get scene, 'kiddo'
    expect Entity.progressForTimeline.get kiddo, @timelineId
      .toBe 1
    expect Entity.position.get kiddo
      .toEqual Vector2.make 1, 1

    @prefilled.dispatch
      type: k.DeltaTime
      data:
        delta: -0.1

    scene = @prefilled.getState()
    kiddo = Scene.entityByName.get scene, 'kiddo'
    expect Entity.progressForTimeline.get kiddo, @timelineId
      .toBe 0.9
    expect Entity.position.get kiddo
      .toEqual Vector2.make 0.9, 0.9
