_ = require 'lodash'
Timeline = require './Timeline'
Path = require '../graphics/Path'

class PathTimeline extends Timeline
  @make: (path) ->
    _.assign (new PathTimeline()),
      class: 'PathTimeline'
      path: path

  # Timeline

  ###
  Modifies the provided `entity` according to the timeline's `progress`.

    timeline - the invoking `PathTimeline`
    progress: Float - a number between 0 and 1, the progress of the timeline.
    entity: Entity
    returns a modified copy of `entity`
  ###
  @mapping: (timeline, progress, entity) ->
    dst = Path.pointAt timeline.path, progress
    delta = Vector2.subtract dst, (Entity.getPosition entity)
    Entity.translate entity, delta


module.exports = PathTimeline