socialDefaults =
  href: 'http://talk.planethunter.org/'
  title: 'Planet Hunters'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @planet_hunter'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'planet_hunter'
    projectName: 'Planet Hunters'
    prefix: 'PH'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'planet_hunter'
    projectName: 'Planet Hunters'
    prefix: 'PH'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'planet_hunter'
    projectName: 'Planet Hunters'
    prefix: 'PH'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/planet_hunter/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'planet_hunter'
    projectName: 'Planet Hunters'
    prefix: 'PH'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.planethunter.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.planethunter.org'
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
