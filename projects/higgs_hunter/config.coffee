socialDefaults =
  href: 'http://talk.higgshunters.org/'
  title: 'Higgs Hunters'
  summary: 'Uncover the building blocks of the universe'
  image: 'http://static.zooniverse.org/www.higgshunters.org/atlas.jpg'
  twitterTags: 'via @higgs_hunter'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'higgs_hunter'
    projectName: 'Higgs Hunters'
    prefix: 'HH'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'higgs_hunter'
    projectName: 'Higgs Hunters'
    prefix: 'HH'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'higgs_hunter'
    projectName: 'Higgs Hunters'
    prefix: 'HH'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/higgs_hunter/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
    app: app
  
  production:
    project: 'higgs_hunter'
    projectName: 'Higgs Hunters'
    prefix: 'HH'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.higgshunters.org/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics:
      account: 'UA-1224199-60'
      domain: 'http://talk.higgshunters.org'
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
