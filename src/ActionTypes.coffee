editorActions = [
  # Removes (deletes) an entity from the scene.
  #
  #   entity: String
  'RemoveEntity'

  # Copies a prototype Entity into the scene.
  #
  # proto: Entity
  # transform: Transform
  'StampPrototype'

  # Parents one entity to another.
  #
  #  parent: String
  #  child: String
  'SetParent'

  # Empowers a Character with a Machine.
  #
  #  character: String
  #  machine: String
  'GiveMachineToCharacter'
]


sceneActions = [
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