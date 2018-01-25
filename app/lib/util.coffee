config = require './config'

SHORT_WORDS = ['and', 'to', 'the']

module.exports =
  capitalize: (string) ->
    string.replace /^(\w)/, (c) -> c.toUpperCase()

  truther: (bool) ->
    if bool then 'yes' else 'no'

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
    return text unless typeof text is 'string'
    return text if text.length <= length
    text.substring(0, length).replace(/\s?\w+$/, '') + '...'

  titleize: (text) ->
    # There's probably a million holes in this
    text.replace /([-_ ]|^)(\w)/g, (match, separator, letter) ->
      " #{ letter.toUpperCase() }"
    .trim()
    .split(' ')
    .map (word, index) ->
      return word if index is 0
      if word.toLowerCase() in SHORT_WORDS
        word.toLowerCase()
      else
        word
    .join(' ')

  formatNumber: (n) ->
    return n unless n
    n.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

  equalObjects: (a, b) ->
    for own key, val of a
      return false unless key of b
      
      if val is Object(val)
        return false unless arguments.callee(val, b[key])
      else
        return false if b[key] isnt val
    
    for own key, val of b
      return false unless key of a
      
      if val is Object(val)
        return false unless arguments.callee(val, a[key])
      else
        return false if a[key] isnt val
    
    true

  getCategoryLabel: (category) ->
    categoryLabels = config?.app?.categoryLabels || {}
    if category of categoryLabels then categoryLabels[category] else category
