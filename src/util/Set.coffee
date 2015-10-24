_ = require 'lodash'

###
Simple immutable set implementation.
###
class Set
  @withHashFunction: (hashFunction, initial = []) ->
    set = _.assign (new Set()),
      _hash: hashFunction
      _elements: Object.freeze {}

    initial.reduce Set.put, set

  @withHashProperty: (hashProperty, initial = []) ->
    set = _.assign (new Set()),
      _hash: (obj) -> obj[hashProperty]
      _elements: Object.freeze {}

    initial.reduce Set.put, set


  # Access

  @get: (set, hash) ->
    set._elements[hash]

  @contains: (set, element) ->
    console.log 'contains', set, element
    set._elements[set._hash element]?

  @count: (set) ->
    (Object.keys set._elements).length

  @find: (set, predicate) ->
    _.find (Set.asArray set), predicate

  @asArray: (set) ->
    _.values set._elements

  @asObject: (set) ->
    set._elements


  # Mutation

  @put: (set, element) ->
    delta = {}
    delta[set._hash element] = element

    _.assign {}, set,
      _elements: _.assign {}, set._elements, delta

  @remove: (set, element) ->
    hash = set._hash element

    _.assign {}, set,
      _elements: _.omit set._elements, hash


module.exports = Set