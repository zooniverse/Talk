socialDefaults =
  href: 'http://talk.higgshunter.org/'
  title: 'Higgs Hunters'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
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
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'higgs_hunter'
    projectName: 'Higgs Hunters'
    prefix: 'HH'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'higgs_hunter'
    projectName: 'Higgs Hunters'
    prefix: 'HH'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/higgs_hunter/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'higgs_hunter'
    projectName: 'Higgs Hunters'
    prefix: 'HH'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.higgshunter.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.higgshunter.org'
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
