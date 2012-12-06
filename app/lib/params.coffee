search = document.location.hash.split('?')[1]
query = if search then search.replace('?', '').split('&') else []
params = { }

for string in query
  [key, value] = string.split '='
  params[key] = value


module.exports = params
