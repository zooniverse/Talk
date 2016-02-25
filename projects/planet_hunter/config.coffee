socialDefaults =
  href: 'http://talk.planethunters.org/'
  title: 'Planet Hunters'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @planethunters'

app =
  categories: ['help', 'science', 'chat']
  extraNav:
    "Old Talk" : "http://oldtalk.planethunters.org"

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
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/planethunter/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app

  production:
    project: 'planet_hunter'
    projectName: 'Planet Hunters'
    prefix: 'PH'
    apiHost: 'https://www.planethunters.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'https://www.planethunters.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-25'
      domain: 'http://talk.planethunters.org'
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
