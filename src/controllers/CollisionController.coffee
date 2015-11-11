Set = require '../util/Set'

# TODO: having access to which entities changed within the last update would
#       make this much more efficient...
checkCollisions = (scene) ->
  if scene.constructor.name isnt 'Scene'
    throw new Error 'checkCollisions() supplied a non-Scene input.'

  entityArray = Set.asArray.get scene.entities

  entityArray
    .map (entityA, idx) ->
      if idx isnt (entityArray.length - 1)
        (entityArray.splice (idx + 1)).map (entityB) ->
          entityA: entityA
          entityB: entityB
          collision: Entity.checkCollision entityA, entityB
    .reduce ((a, b) -> a.concat b), []
    .filter (x) -> x.collision?