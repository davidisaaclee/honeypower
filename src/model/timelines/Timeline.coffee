_ = require 'lodash'

###
Abstraction for timelines for use with Darko timeline library.

Timeline ::=
  id: String
  type: String
  data: Object
  [updateMethod: String]
###
class Timeline
  @UpdateMethod:
    Time: 'Time'

  @make: do ->
    spawnCount = 0
    return (type, data, id) ->
      config =
        id: id
        type: type
        data: data

      fields = _.defaults config,
        id: "timeline-#{spawnCount++}"

      _.assign new Timeline(), fields

  ###
  Modifies `data` according to the timeline's `progress`.

    timeline: Timeline - the invoking `PathTimeline`
    progress: Float - a number between 0 and 1, the progress of the timeline.
    data: Object - an arbitrary object used as the procedure's base value
    returns a modified copy of `data` - an Object
  ###
  @mapping: (timeline, progress, data) ->
    console.warn 'Timeline extension should override `mapping()`.'
    return data

  ###
  Returns this `Timeline`'s type as a string.

    timeline - the invoking `Timeline`.
  ###
  @getType: (timeline) -> timeline.type


  # Mutation

  @setUpdateMethod: (timeline, updateMethod) ->
    _.assign {}, timeline,
      updateMethod: updateMethod


module.exports = Timeline