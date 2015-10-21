editorActions = [
  # obviated by `StampPrototype`
  # # Adds a new entity to the scene.
  # #
  # #   name: String
  # #   transform: Transform
  # #   children: [Entity]
  # 'AddEntity'

  # Removes (deletes) an entity from the scene.
  #
  #   entity: String
  'RemoveEntity'

  # Copies a prototype Entity into the scene.
  #
  # proto: Entity
  # transform: Transform
  'StampPrototype'

  # # Creates and adds a new trigger entity to the scene.
  # #
  # #   name: String
  # #   position: Vector2
  # #   shape: Path
  # #   transform: Transform
  # 'PutTrigger'

  # # Creates and adds a new character entity to the scene.
  # #
  # #   name: String
  # #   spriteId: String
  # #   position: Vector2
  # #   transform: Transform
  # 'PutCharacter'

  # # Creates and adds a new machine entity to the scene.
  # #
  # #   name: String
  # #   machine: Machine
  # #   position: Vector2
  # #   transform: Transform
  # 'PutMachine'

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
  # i don't think we need this; is it too complex to have a bin of unused entities?
  # # Creates a new entity. The new entity is simply created and held in the
  # #   entity database for reference.
  # #
  # #   name: String
  # #   transform: Transform
  # #   children: [Entity]
  # 'CreateEntity'

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