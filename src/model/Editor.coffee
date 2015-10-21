_ = require 'lodash'
Model = require './Model'

class Editor extends Model
  @make: (scene) ->
    _.assign (new Editor()),
      scene: scene

  @empty: Object.freeze Editor.make()

module.exports = Editor