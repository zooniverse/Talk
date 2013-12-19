socialDefaults =
  href: 'http://radiotalk.galaxyzoo.org/'
  title: 'Galaxy Zoo: Radio'
  summary: 'In Search of Erupting Black Holes'
  image: 'http://radio.galaxyzoo.org/images/science/pictor.jpg'
  twitterTags: 'via @galaxyzoo'

Config =
  test:
    project: 'radio'
    projectName: 'Galaxy Zoo: Radio'
    prefix: 'RZ'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
  
  developmentLocal:
    project: 'radio'
    projectName: 'Galaxy Zoo: Radio'
    prefix: 'RZ'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
  
  developmentRemote:
    project: 'radio'
    projectName: 'Galaxy Zoo: Radio'
    prefix: 'RZ'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://radio.galaxyzoo.org/beta2/'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
  
  production:
    project: 'radio'
    projectName: 'Galaxy Zoo: Radio'
    prefix: 'RZ'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://radio.galaxyzoo.org/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics:
      account: 'UA-1224199-49"'
      domain: 'http://radio.galaxyzoo.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
