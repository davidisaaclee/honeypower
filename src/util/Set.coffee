_ = require 'lodash'
Lens = require 'lens'

###
Simple immutable set implementation.
###
class Set
  constructor: (hashFunction = Object.prototype.toString, elementDict = {}) ->
    @_hash = hashFunction
    @_elements = elementDict

  @withHashFunction: (hashFunction, initial = []) ->
    set = new Set hashFunction, Object.freeze {}
    initial.reduce Set.put, set

  @withHashProperty: (hashProperty, initial = []) ->
    set = new Set (_.property hashProperty), Object.freeze {}
    initial.reduce Set.put, set


  # Lenses

  @element: Lens.fromPath (hash) -> ['_elements', hash]

  @asArray: new Lens \
    (set) -> _.values set._elements,
    (set, array) -> array.reduce Set.put, (Set.clear set)


  # Access

  @get: (set, hash) -> Set.element.get set, hash

  @contains: (set, element) -> (Set.element.get set, set._hash element)?

  @count: (set) -> (Object.keys set._elements).length

  @find: (set, predicate) -> _.find (Set.asArray.get set), predicate

  @keys: (set) -> Object.keys set._elements


  # Mutation

  @put: (set, element) -> Set.element.set set, (set._hash element), element

  @remove: (set, element) -> Set.removeByHash set, set._hash element

  @removeByHash: (set, hash) -> _.assign {}, set,
    _elements: _.omit set._elements, hash

  @clear: (set) -> (Set.asArray.get set).reduce Set.remove, set


module.exports = Set