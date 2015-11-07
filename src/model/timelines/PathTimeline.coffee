_ = require 'lodash'
Lens = require 'lens'
Timeline = require './Timeline'
Path = require '../graphics/Path'
Vector2 = require '../graphics/Vector2'
Transform = require '../graphics/Transform'

class PathTimeline extends Timeline
  @make: (path) ->
    _.assign (new PathTimeline()),
      class: 'PathTimeline'
      path: path

  @path: Lens.fromPath 'data.path'


  # Timeline

  ###
  Modifies the provided `data` according to the timeline's `progress`.

    timeline: Timeline - the invoking `PathTimeline`
    progress: Float - a number between 0 and 1, the progress of the timeline.
    data: Object - arbitrary data to be modified
    returns a modified copy of `data`
  ###
  @mapping: (timeline, progress, data) ->
    dst = Path.pointAt (PathTimeline.path.get timeline), progress
    delta = Vector2.subtract dst, (Transform.getPosition data.transform)

    _.assign {}, data,
      transform: Transform.translate data.transform, delta


module.exports = PathTimeline