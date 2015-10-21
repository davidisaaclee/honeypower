_ = require 'lodash'
Model = require '../Model'
Vector2 = require './Vector2'

class Path extends Model
  @make: (position = Vector2.zero, segments = []) ->
    _.assign (new Path()),
      position: position
      segments: segments

  @empty: Object.freeze Path.make()


  # Mutation

  @addSegment: (path, segment) ->
    _.assign {}, path,
      segments: [path.segments..., segment]