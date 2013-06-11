module.exports =
  parse: (hash) ->
    hash or= document.location.hash
    search = hash.split('?')[1]
    query = if search then search.replace('?', '').split('&') else []
    params = { }
    
    for string in query
      [key, value] = string.split '='
      
      [totalMatch, arrayKey] = key.match(/\[\]$/) or []
      [totalMatch, hashKey, hashValueKey] = key.match(/([-\w\d]+)\[([-\w\d]+)\]/) or []
      
      if arrayKey
        params[arrayKey] or= []
        params[arrayKey].push value
      else if hashKey and hashValueKey
        params[hashKey] or= { }
        params[hashKey][hashValueKey] = value
      else
        params[key] = value
    
    params
