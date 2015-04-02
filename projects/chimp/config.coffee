socialDefaults =
  href: 'http://talk.chimpandsee.org/'
  title: 'Chimp & See'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @chimp'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'chimp'
    projectName: 'Chimp & See'
    prefix: 'CP'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'chimp'
    projectName: 'Chimp & See'
    prefix: 'CP'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'chimp'
    projectName: 'Chimp & See'
    prefix: 'CP'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.chimpandsee.org/beta/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  production:
    project: 'chimp'
    projectName: 'Chimp & See'
    prefix: 'CP'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.chimpandsee.org/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics:
      account: 'UA-1224199-17'
      domain: 'http://talk.chimpandsee.org'
    app: app

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
