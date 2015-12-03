socialDefaults =
  href: 'http://talk.chicagowildlifewatch.org/'
  title: 'Chicago Wildlife Watch'
  summary: 'Explore and understand how animals—from coyotes to chipmunks—share this great city.'
  image: 'http://www.chicagowildlifewatch.org/images/site-logo.svg'
  twitterTags: 'via @LPZ_UWI and @adlerskywatch'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'chicago'
    projectName: 'Chicago Wildlife Watch'
    prefix: 'CH'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'chicago'
    projectName: 'Chicago Wildlife Watch'
    prefix: 'CH'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'chicago'
    projectName: 'Chicago Wildlife Watch'
    prefix: 'CH'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://demo.zooniverse.org/zoo-zoo/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  production:
    project: 'chicago'
    projectName: 'Chicago Wildlife Watch'
    prefix: 'CH'
    apiHost: 'http://www.chicagowildlifewatch.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.chicagowildlifewatch.org/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics:
      account: 'UA-1224199-10'
      domain: 'http://talk.chicagowildlifewatch.org'
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
