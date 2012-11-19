Config =
  test:
    apiHost: null
  
  developmentLocal:
    apiHost: 'http://localhost:3000'
  
  developmentRemote:
    apiHost: 'https://dev.zooniverse.org'
  
  production:
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
