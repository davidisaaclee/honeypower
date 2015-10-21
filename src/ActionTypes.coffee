editorActions = [
  # Adds a new entity to the scene.
  #
  #   entity: String
  #   transform: Transform
  #   children: [Entity]
  'AddEntity'
]


sceneActions = [
]


entityActions = [
  # Creates a new entity. The new entity is simply created and held in the
  #   entity database for reference.
  #
  #   name: String
  #   transform: Transform
  #   children: [Entity]
  'CreateEntity'

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
  #  translate: Vector2
  #  rotate: Number
  #  scale: Vector2
  'TransformEntity'
]


registerAction = (dict, actionType) ->
  dict[actionType] = actionType
  return dict

module.exports =
  [editorActions, sceneActions, entityActions]
    .reduce ((a, b) -> a.concat b), []
    .reduce registerAction, {}