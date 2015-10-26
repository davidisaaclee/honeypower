makeVTable = require '../../util/VTable'
Timeline = require './Timeline'
PathTimeline = require './PathTimeline'

module.exports = makeVTable Timeline.getClass, Timeline,
  'PathTimeline': PathTimeline