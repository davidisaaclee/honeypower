Path = require '../src/model/graphics/Path'
Vector2 = require '../src/model/graphics/Vector2'

describe 'Path', () ->
  it 'can interpolate points on simple line', () ->
    path = Path.make [
      Vector2.make 0, 0
      Vector2.make 1, 1
    ]

    expect Path.pointAt path, 0
      .toEqual Vector2.make 0, 0
    expect Path.pointAt path, 1
      .toEqual Vector2.make 1, 1
    expect Path.pointAt path, 0.5
      .toEqual Vector2.make 0.5, 0.5
    expect Path.pointAt path, 0.25
      .toEqual Vector2.make 0.25, 0.25


  it 'can interpolate points on polyline', () ->
    path = Path.make [
      Vector2.make 0, 0
      Vector2.make 0, 1
      Vector2.make 1, 1
      Vector2.make 1, 0
      Vector2.make 0, 0
    ]

    expect Path.pointAt path, 0
      .toEqual Vector2.make 0, 0
    expect Path.pointAt path, 0.25
      .toEqual Vector2.make 0, 1
    expect Path.pointAt path, 0.5
      .toEqual Vector2.make 1, 1
    expect Path.pointAt path, 0.75
      .toEqual Vector2.make 1, 0
    expect Path.pointAt path, 1
      .toEqual Vector2.make 0, 0


    path2 = Path.make [
      Vector2.make 0, 0
      Vector2.make 0, 4
      Vector2.make 4, 4
    ]

    expect Path.pointAt path2, 0
      .toEqual Vector2.make 0, 0
    expect Path.pointAt path2, 0.25
      .toEqual Vector2.make 0, 2
    expect Path.pointAt path2, 0.5
      .toEqual Vector2.make 0, 4
    expect Path.pointAt path2, 0.75
      .toEqual Vector2.make 2, 4
    expect Path.pointAt path2, 1
      .toEqual Vector2.make 4, 4


  it 'respects line offset', () ->
    # TODO