socialDefaults =
  href: 'http://talk.wormwatchlab.org/'
  title: 'Worm Watch Lab'
  summary: 'Detecting genetic abnormalities in C. elegans!'
  image: 'TODO'
  twitterTags: 'via @worms'

Config =
  test:
    project: 'worms'
    projectName: 'Worm Watch Lab'
    prefix: 'WS'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'worms'
    projectName: 'Worm Watch Lab'
    prefix: 'WS'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:2217/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'worms'
    projectName: 'Worm Watch Lab'
    prefix: 'WS'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/worms/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'worms'
    projectName: 'Worm Watch Lab'
    prefix: 'WS'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.wormwatchlab.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-44'
      domain: 'http://talk.wormwatchlab.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
