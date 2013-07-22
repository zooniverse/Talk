socialDefaults =
  href: 'http://talk.plankton.org/'
  title: 'Plankton'
  summary: 'Inspecting diversity of plankton species!'
  image: ''
  twitterTags: 'via @plankton'

Config =
  test:
    project: 'plankton'
    projectName: 'Plankton'
    prefix: 'PK'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'plankton'
    projectName: 'Plankton'
    prefix: 'PK'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'plankton'
    projectName: 'Plankton'
    prefix: 'PK'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/plankton/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'plankton'
    projectName: 'Plankton'
    prefix: 'PK'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.plankton.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.plankton.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
