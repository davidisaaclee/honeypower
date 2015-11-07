_ = require 'lodash'
{createStore} = require 'redux'
k = require '../src/ActionTypes'
editorReducer = require '../src/reducers/EditorReducer'
Scene = require '../src/model/Scene'
Editor = require '../src/model/Editor'
Kit = require '../src/model/Kit'
Prototype = require '../src/model/Prototype'
Timeline = require '../src/model/timelines/Timeline'
Entity = require '../src/model/entities/Entity'
Vector2 = require '../src/model/graphics/Vector2'
Path = require '../src/model/graphics/Path'
Transform = require '../src/model/graphics/Transform'

describe 'Editor:', () ->
  beforeEach () ->
    birdo = Entity.make 'birdoProto'
    kiddo = Entity.make 'kiddoProto'

    birdoProto = Prototype.make 'birdo', birdo
    kiddoProto = Prototype.make 'kiddo', kiddo

    birdoKiddoKit = Kit.with 'birdoKiddo', [birdoProto, kiddoProto], [], []

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


  # Copies a prototype Entity into the scene.
  #
  #   proto: String
  #   transform: Transform
  #   name: String
  #   [onto: String | null]
  #     set to null or undefined for placing directly into scene
  it 'StampPrototype (onto scene)', () ->
    birdoProto = Editor.getPrototype @store.getState(), 'birdo'
    expect Entity.getPosition (Prototype.getDefinition birdoProto)
      .toEqual (Vector2.make 0, 0)
    expect (Scene.getAllEntities @store.getState().scene)
      .toEqual []

    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        name: 'birdoStamp'
        transform: Transform.withPosition (Vector2.make 10, 10)

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 1
    expect Entity.getName (Scene.getAllEntities @store.getState().scene)[0]
      .toEqual 'birdoStamp'
    expect Entity.getPosition (Scene.getAllEntities @store.getState().scene)[0]
      .toEqual (Vector2.make 10, 10)
    birdoProto = Editor.getPrototype @store.getState(), 'birdo'
    expect Entity.getPosition (Prototype.getDefinition birdoProto)
      .toEqual (Vector2.make 0, 0)

    @store.dispatch
      type: k.StampPrototype
      data:
        id: 'myBirdo'
        proto: 'birdo'

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 2
    expect (Scene.getEntity @store.getState().scene, 'myBirdo')
      .toBeDefined()


  # Removes (deletes) an entity from the scene.
  #
  #   entity: String
  it 'RemoveEntity', () ->
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        name: 'birdoStamp'
        transform: Transform.withPosition (Vector2.make 10, 10)

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 1
    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'

    @store.dispatch
      type: k.RemoveEntity
      data:
        entity: birdoInstance.id

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 0

    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        name: 'birdoStamp'
        transform: Transform.withPosition (Vector2.make 10, 10)
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'kiddo'
        onto: null
        name: 'kiddoStamp'
        transform: Transform.withPosition (Vector2.make 10, 10)

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 2
    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'

    @store.dispatch
      type: k.RemoveEntity
      data:
        entity: birdoInstance.id

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'
    kiddoInstance = Scene.getEntityByName @store.getState().scene, 'kiddoStamp'

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 1
    expect birdoInstance
      .toBeUndefined()
    expect kiddoInstance
      .toBeDefined()

    @store.dispatch
      type: k.RemoveEntity
      data:
        entity: kiddoInstance.id

    expect (Scene.getAllEntities @store.getState().scene).length
      .toBe 0


  # Transform an `Entity`'s static transform.
  #
  #  entity: String
  #  transform: Transform
  it 'TransformEntity', () ->
    initialPosition = Vector2.make 10, 10
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        name: 'birdoStamp'
        onto: null
        transform: Transform.withPosition initialPosition

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'
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

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'
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

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'
    expect Entity.getPosition birdoInstance
      .toEqual (Vector2.add initialPosition, (Vector2.scale translationAmount, 2))
    expect Entity.getRotation birdoInstance
      .toBeCloseTo (Math.PI / 2)
    expect Entity.getScale birdoInstance
      .toEqual (Vector2.make 2, 1)

    @store.dispatch
      type: k.TransformEntity
      data:
        entity: birdoInstance.id
        transform: Transform.withScale (Vector2.make 3, 2)

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'
    expect Entity.getPosition birdoInstance
      .toEqual (Vector2.add initialPosition, (Vector2.scale translationAmount, 2))
    expect Entity.getRotation birdoInstance
      .toBeCloseTo (Math.PI / 2)
    expect Entity.getScale birdoInstance
      .toEqual (Vector2.make 6, 2)


  # Copies a prototype Entity into the scene.
  #
  #   proto: String
  #   transform: Transform
  #   name: String
  #   [onto: String | null]
  #     set to null or undefined for placing directly into scene
  it 'StampPrototype (onto entities)', () ->
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        onto: null
        name: 'birdoStamp'
        transform: Transform.withPosition (Vector2.make 10, 10)

    birdoInstance = Scene.getEntityByName @store.getState().scene, 'birdoStamp'

    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'kiddo'
        name: 'kiddoStamp'
        onto: birdoInstance.id
        transform: Transform.withPosition (Vector2.make 0, 0)

    birdoInstance =
      Scene.getEntityByName @store.getState().scene, 'birdoStamp'
    expect birdoInstance
      .toBeDefined()

    kiddoInstance =
      Scene.getEntityByName @store.getState().scene, 'kiddoStamp'
    expect kiddoInstance
      .toBeDefined()

    expect Entity.getChild birdoInstance
      .not.toBeNull()
    expect (Entity.getChild birdoInstance).name
      .toBe 'kiddoStamp'
    expect Entity.getChild birdoInstance
      .toEqual kiddoInstance
    expect Entity.getChild kiddoInstance
      .toBeNull()


  # Links one entity to another. This will behave differently according to the
  #  types of `Entity`s.
  #
  #   parent: String
  #   child: String
  it 'LinkEntities', () ->
    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'birdo'
        name: 'birdoStamp'
        transform: Transform.withPosition (Vector2.make 10, 10)

    @store.dispatch
      type: k.StampPrototype
      data:
        proto: 'kiddo'
        name: 'kiddoStamp'
        transform: Transform.withPosition (Vector2.make 10, 10)

    birdoInstance_ =
      Scene.getEntityByName @store.getState().scene, 'birdoStamp'
    kiddoInstance_ =
      Scene.getEntityByName @store.getState().scene, 'kiddoStamp'

    @store.dispatch
      type: k.LinkEntities
      data:
        parent: birdoInstance_.id
        child: kiddoInstance_.id

    scene = @store.getState().scene
    birdoInstance = Scene.getEntityByName scene, 'birdoStamp'
    expect birdoInstance
      .toBeDefined()

    kiddoInstance = Scene.getEntityByName scene, 'kiddoStamp'
    expect kiddoInstance
      .toBeDefined()

    expect Entity.getChild birdoInstance
      .toBeDefined()
    expect (Entity.getChild birdoInstance).name
      .toEqual 'kiddoStamp'
    expect Entity.getChild (Entity.getChild birdoInstance)
      .toBeNull()


  # Registers a new timeline.
  #
  #   type: String     # type of this timeline
  #   data: Object      # data specific to the timeline type
  it 'RegisterTimeline', () ->
    @store.dispatch
      type: k.RegisterTimeline
      data:
        type: 'PathTimeline'
        data:
          path: Path.make (Vector2.make 0, 0), [
            Vector2.make 0, 0
            Vector2.make 1, 0
          ]

    scene = @store.getState().scene
    expect (Scene.getAllTimelines scene).length
      .toBe 1

    timeline = _.head Scene.getAllTimelines scene
    expect Scene.getTimelineById scene, timeline.id
      .toBe timeline
    expect timeline['type']
      .toBe 'PathTimeline'

    @store.dispatch
      type: k.RegisterTimeline
      data:
        id: 'myTimeline'
        type: 'MockTimeline'
        data:
          path: Path.make (Vector2.make 0, 0), [
            Vector2.make 0, 0
            Vector2.make 1, 0
          ]

    scene = @store.getState().scene
    expect (Scene.getAllTimelines scene).length
      .toBe 2
    expect Scene.getTimelineById scene, 'myTimeline'
      .toBeDefined()
    expect Timeline.type.get (Scene.getTimelineById scene, 'myTimeline')
      .toEqual 'MockTimeline'


  # Attach a timeline to an entity.
  #   timeline: String
  #   entity: String
  #   [progress: Float]     # initial progress; defaults to 0
  #   [stackPosition: Int]  # position in timeline stack; defaults to 0 (top)
  it 'AttachTimeline', () ->
    @store.dispatch
      type: k.RegisterTimeline
      data:
        id: 'timeline1'
        class: 'PathTimeline'
        data:
          path: Path.make (Vector2.make 0, 0), [
            Vector2.make 0, 0
            Vector2.make 1, 0
          ]
    @store.dispatch
      type: k.RegisterTimeline
      data:
        id: 'timeline2'
        class: 'PathTimeline'
        data:
          path: Path.make (Vector2.make 0, 0), [
            Vector2.make 0, 0
            Vector2.make 1, 0
          ]
    @store.dispatch
      type: k.StampPrototype
      data:
        id: 'b'
        proto: 'birdo'
        name: 'birdoStamp'
    @store.dispatch
      type: k.StampPrototype
      data:
        id: 'k'
        proto: 'kiddo'
        name: 'kiddoStamp'

    scene = @store.getState().scene
    expect Entity.getTimelineStack Scene.getEntity scene, 'b'
      .toEqual []
    expect Entity.getTimelineStack Scene.getEntity scene, 'k'
      .toEqual []

    @store.dispatch
      type: k.AttachTimeline
      data:
        timeline: 'timeline1'
        entity: 'b'

    scene = @store.getState().scene
    expect Entity.getTimelineStack Scene.getEntity scene, 'b'
      .toEqual ['timeline1']
    expect Entity.getProgressForTimeline (Scene.getEntity scene, 'b'), 'timeline1'
      .toBe 0

    @store.dispatch
      type: k.AttachTimeline
      data:
        timeline: 'timeline2'
        entity: 'b'
        progress: 0.2

    scene = @store.getState().scene
    expect Entity.getTimelineStack Scene.getEntity scene, 'b'
      .toEqual ['timeline2', 'timeline1']
    expect Entity.getProgressForTimeline (Scene.getEntity scene, 'b'), 'timeline1'
      .toBe 0
    expect Entity.getProgressForTimeline (Scene.getEntity scene, 'b'), 'timeline2'
      .toBe 0.2

    @store.dispatch
      type: k.AttachTimeline
      data:
        timeline: 'timeline1'
        entity: 'k'
    @store.dispatch
      type: k.AttachTimeline
      data:
        timeline: 'timeline2'
        entity: 'k'
        stackPosition: 1
        progress: 0.5

    scene = @store.getState().scene
    expect Entity.getTimelineStack Scene.getEntity scene, 'k'
      .toEqual ['timeline1', 'timeline2']
    expect Entity.getProgressForTimeline (Scene.getEntity scene, 'k'), 'timeline2'
      .toBe 0.5
    expect Entity.getProgressForTimeline (Scene.getEntity scene, 'k'), 'timeline1'
      .toBe 0


  # Detach a timeline from an entity.
  #   timeline: String
  #   entity: String
  it 'DetachTimeline', () ->
    @store.dispatch
      type: k.RegisterTimeline
      data:
        id: 'timeline1'
        class: 'PathTimeline'
        data:
          path: Path.make (Vector2.make 0, 0), [
            Vector2.make 0, 0
            Vector2.make 1, 0
          ]
    @store.dispatch
      type: k.RegisterTimeline
      data:
        id: 'timeline2'
        class: 'PathTimeline'
        data:
          path: Path.make (Vector2.make 0, 0), [
            Vector2.make 0, 0
            Vector2.make 1, 0
          ]
    @store.dispatch
      type: k.StampPrototype
      data:
        id: 'b'
        proto: 'birdo'
        name: 'birdoStamp'
    @store.dispatch
      type: k.StampPrototype
      data:
        id: 'k'
        proto: 'kiddo'
        name: 'kiddoStamp'
    @store.dispatch
      type: k.AttachTimeline
      data:
        timeline: 'timeline1'
        entity: 'b'
    @store.dispatch
      type: k.AttachTimeline
      data:
        timeline: 'timeline2'
        entity: 'b'
        progress: 0.2

    @store.dispatch
      type: k.DetachTimeline
      data:
        timelineIndex: 0
        entity: 'b'

    scene = @store.getState().scene
    expect Entity.getTimelineStack Scene.getEntity scene, 'b'
      .toEqual ['timeline1']
    expect Entity.getProgressForTimeline (Scene.getEntity scene, 'b'), 'timeline1'
      .toBe 0

    @store.dispatch
      type: k.AttachTimeline
      data:
        timeline: 'timeline2'
        entity: 'b'
        stackPosition: 1
    @store.dispatch
      type: k.DetachTimeline
      data:
        timelineIndex: 1
        entity: 'b'

    scene = @store.getState().scene
    expect Entity.getTimelineStack Scene.getEntity scene, 'b'
      .toEqual ['timeline1']
    expect Entity.getProgressForTimeline (Scene.getEntity scene, 'b'), 'timeline1'
      .toBe 0


  # Set how the specified timeline will be controlled.
  #
  #   timeline: String
  #   playbackMethod: 'time' | 'touchX' | 'touchY' | etc
  xit 'SetTimelinePlaybackMethod', () ->


  # TODO: this has a bunch of new specs about registering kits
  # Request specific editor for the specified `Entity`.
  #
  #   entity: String
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