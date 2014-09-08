socialDefaults =
  href: 'http://talk.penguinwatch.org/'
  title: 'Penguin Watch'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @penguin'

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
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'penguin'
    projectName: 'Penguin Watch'
    prefix: 'PZ'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'penguin'
    projectName: 'Penguin Watch'
    prefix: 'PZ'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.penguinwatch.org/beta/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'penguin'
    projectName: 'Penguin Watch'
    prefix: 'PZ'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.penguinwatch.org/#/classify'
    socialDefaults: socialDefaults
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
  'developmentRemote'
  # 'production'

module.exports = Config[env]
