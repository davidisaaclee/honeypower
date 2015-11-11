###
Sort a list into pairs, such that each element (except the end elements) is in a
  pair with its preceding and succeeding element.

  [1, 2, 3, 4]
  -> [[1, 2], [2, 3], [3, 4]]

  [3, 2, 1]
  -> [[3, 2], [2, 1]]
###
module.exports = pairs = (l) ->
  result = []
  if l.length > 0
    for i in [0...(l.length - 1)]
      result.push [l[i], l[i + 1]]
  return result