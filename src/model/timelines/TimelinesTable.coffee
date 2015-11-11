makeVTable = require '../../util/VTable'
Timeline = require './Timeline'
PathTimeline = require './PathTimeline'


module.exports = makeVTable Timeline.type.get, Timeline,
  'PathTimeline': PathTimeline