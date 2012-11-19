Config =
  test:
    project: 'serengeti'
    apiHost: null
  
  developmentLocal:
    project: 'serengeti'
    apiHost: 'http://localhost:3000'
  
  developmentRemote:
    project: 'serengeti'
    apiHost: 'https://dev.zooniverse.org'
  
  production:
    project: 'serengeti'
    apiHost: 'https://api.zooniverse.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
