makeVTable = require '../src/util/VTable'

describe 'VTable', () ->
  it 'basically works', () ->
    class Foo
      fn: (self, x) -> x

    class Bar
      fn: (self, x) -> x * 2

    class Qux
      fn: (self, x) -> x * 10

    getType = (x) -> x.type
    vtable = makeVTable getType, Foo.prototype,
      'Bar': Bar.prototype
      'Qux': Qux.prototype

    expect vtable.fn { type: undefined }, 3
      .toBe 3
    expect vtable.fn { type: 'Bar' }, 3
      .toBe 6
    expect vtable.fn { type: 'Qux' }, 3
      .toBe 30

  it 'works with class methods', () ->
    class Foo
      @fn: (self, x) -> x

    class Bar
      @fn: (self, x) -> x * 2

    class Qux
      @fn: (self, x) -> x * 10

    getType = (x) -> x.type
    vtable = makeVTable getType, Foo,
      'Bar': Bar
      'Qux': Qux

    expect vtable.fn { type: undefined }, 3
      .toBe 3
    expect vtable.fn { type: 'Bar' }, 3
      .toBe 6
    expect vtable.fn { type: 'Qux' }, 3
      .toBe 30