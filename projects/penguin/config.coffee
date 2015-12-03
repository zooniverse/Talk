socialDefaults =
  href: 'http://talk.penguinwatch.org/'
  title: 'Penguin Watch'
  summary: 'Monitor Penguins in Remote Regions'
  image: 'http://static.zooniverse.org/www.penguinwatch.org/penguins-fpo.jpg'
  twitterTags: 'via @penguin_watch'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'penguin'
    projectName: 'Penguin Watch'
    prefix: 'PZ'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'penguin'
    projectName: 'Penguin Watch'
    prefix: 'PZ'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'penguin'
    projectName: 'Penguin Watch'
    prefix: 'PZ'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.penguinwatch.org/beta/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  production:
    project: 'penguin'
    projectName: 'Penguin Watch'
    prefix: 'PZ'
    apiHost: 'http://www.penguinwatch.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.penguinwatch.org/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics:
      account: 'UA-1224199-57'
      domain: 'http://talk.penguinwatch.org'
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
