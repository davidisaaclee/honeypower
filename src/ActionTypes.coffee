editorActions = [
  # Editing scene

  # Copies a prototype Entity into the scene.
  #
  #   proto: String
  #   transform: Transform
  #   name: String
  #   [onto: String | null]
  #     set to null or undefined for placing directly into scene
  'StampPrototype'

  # Removes (deletes) an entity from the scene.
  #
  #   entity: String
  'RemoveEntity'


  # Editing entities

  # Transform an `Entity`'s static transform.
  #
  #   entity: String
  #   transform: Transform
  'TransformEntity'

  # Links one entity to another. This will behave differently according to the
  #  types of `Entity`s.
  #
  #   parent: String
  #   child: String
  'LinkEntities'

  # Request specific editor for the specified `Entity`.
  #
  #   entity: String
  'RequestEntityEditor'


  # TODO: still need to test all timeline actions
  # Timelines

  # # Registers a new Darko timeline, optionally attaching it to an `Entity`.
  # #
  # #   mapping: (data, progress) -> data
  # #   [entity: String]
  # 'RegisterTimeline'

  # Registers a new Darko timeline.
  #
  #   class: String     # class of this timeline
  #   data: Object      # data specific to the timeline class
  'RegisterTimeline'

  # Attach a timeline to an entity.
  #   timeline: String
  #   entity: String
  'AttachTimeline'

  # Detach a timeline from an entity.
  #   timeline: String
  #   entity: String
  'DetachTimeline'

  # Set how the specified timeline will be controlled.
  #
  #   timeline: String
  #   playbackMethod: 'time' | 'touchX' | 'touchY' | etc
  'SetTimelinePlaybackMethod'
]


sceneActions = [
  # Denotes the passing of time. Can be positive, zero, or negative.
  #
  #   delta: Number
  'DeltaTime'
]


entityActions = [
  # Add a child to an entity.
  #
  #  parent: String
  #  child: String
  'AddChild'

  # Remove a child from an entity.
  #
  #  parent: String
  #  child: String
  'RemoveChild'

  # Transform an entity.
  #
  #  entity: String
  #  [translate: Vector2]
  #  [rotate: Number]
  #  [scale: Vector2]
  'TransformEntity'
]


registerAction = (dict, actionType) ->
  dict[actionType] = actionType
  return dict

module.exports =
  [editorActions, sceneActions, entityActions]
    .reduce ((a, b) -> a.concat b), []
    .reduce registerAction, {}