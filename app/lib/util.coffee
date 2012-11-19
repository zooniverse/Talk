module.exports =
  capitalize: (string) ->
    string.replace /^(\w)/, (c) -> c.toUpperCase()
