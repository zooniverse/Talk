module.exports =
  capitalize: (string) ->
    string.replace /^(\w)/, (c) -> c.toUpperCase()
  
  focusCollectionFor: (type) ->
    if type is 'Board'
      'boards'
    else if /Subject$/.test(type)
      'subjects'
    else if /Group$/.test(type)
      'groups'
    else if type in ['SubjectSet', 'KeywordSet']
      'collections'
  
  singularize: (word) ->
    word.replace /s$/, ''
