socialDefaults =
  href: 'http://talk.asteroidzoo.org/'
  title: 'Asteroid Zoo'
  summary: 'Hunt for Resource-Rich Asteroids!'
  image: 'http://www.asteroidzoo.org/images/rock.png'
  twitterTags: 'via @asteroidzoo'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'asteroid'
    projectName: 'Asteroid Zoo'
    prefix: 'AZ'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'asteroid'
    projectName: 'Asteroid Zoo'
    prefix: 'AZ'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'asteroid'
    projectName: 'Asteroid Zoo'
    prefix: 'AZ'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/asteroid/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'asteroid'
    projectName: 'Asteroid Zoo'
    prefix: 'AZ'
    apiHost: 'http://www.asteroidzoo.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.asteroidzoo.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-56'
      domain: 'http://talk.asteroidzoo.org'
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
