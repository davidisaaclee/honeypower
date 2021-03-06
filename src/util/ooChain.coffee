_ = require 'lodash'

###
Utility for writing mutation chains with object-oriented functions.

    # f: (T, a, b) -> T
    # g: (T, c) -> T
    # t: T

    result1 = t
    result1 = f t, a, b
    result1 = g t, c

    result2 = ooChain t
      .then f, a, b
      .then g, c
      .value()

    result1 == result2

    # pending spec
    result3 = ooChain t
      .let 'foo': a
      .let 'bar': b
      .in (lets) -> [f, lets.foo, lets.bar]
      # tapping into stream for a `let` declaration
      .let (v) -> 'qux': v.c
      .in (lets) -> [g, lets.qux]
      .value()
###
module.exports = ooChain = (object, bound = {}) ->
  let: (assignments) ->
    switch
      when _.isFunction assignments
        ooChain object, (_.extend {}, bound, (assignments object, bound))
      when _.isObject assignments
        ooChain object, (_.extend {}, bound, assignments)
      else
        ooChain object, bound
  in: (injection) ->
    ooChain (injection object, bound), bound
  then: (fn, args...) ->
    ooChain (fn object, args...), bound
  value: () -> object