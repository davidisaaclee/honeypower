_ = require 'lodash'
Model = require './Model'

class Editor extends Model
  @make: (scene, factories = []) ->
    _.assign (new Editor()),
      scene: scene
      factories: factories

  @empty: Object.freeze Editor.make()

module.exports = Editor