socialDefaults =
  href: 'http://talk.spacewarp.org/'
  title: 'Spacewarps'
  summary: 'Discovering gravitational lenses'
  image: 'https://si0.twimg.com/profile_images/3468076942/c06223dd495507fdaccfa6a7c24ac055.jpeg'
  twitterTags: 'via @spacewarps'

Config =
  test:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://spacewarps.org/beta/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://spacewarps.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-43'
      domain: 'talk.spacewarps.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
