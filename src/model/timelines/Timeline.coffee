_ = require 'lodash'
Lens = require 'lens'

###
Abstraction for timelines for use with Darko timeline library.

Timeline ::=
  id: String
  type: String
  data: Object
  [updateMethod: String]
###
class Timeline

TimelineFunctions =
  UpdateMethod:
    Time: 'Time'

  make: do ->
    spawnCount = 0
    return (type, length, data, id) ->
      config =
        id: id
        length: length
        type: type
        data: data

      fields = _.defaults config,
        id: "timeline-#{spawnCount++}"

      _.assign new Timeline(), fields

  ###
  Modifies the provided `data` according to the timeline's `progress`.

    timeline: Timeline - the invoking `Timeline`
    progress: Float - a number between 0 and 1, the progress of the timeline.
    data: Object - arbitrary data to be modified
    returns a modified copy of `data`
  ###
  mapping: (timeline, progress, data) ->
    console.warn 'Timeline extension should override `mapping()`.'
    return data


  ### Lenses ###

  type: Lens.fromPath 'type'

  updateMethod: Lens.fromPath 'updateMethod'

  id: Lens.fromPath 'id'

  length: Lens.fromPath 'length'


module.exports = TimelineFunctions