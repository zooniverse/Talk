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
  
  pluralize: (number, singular, plural) ->
    if number > 1 or number is 0 then plural else singular
  
  truncate: (text, length) ->
    return text if text.length <= length
    text.substring(0, length).replace(/\s?\w+$/, '') + '&#8230;'
