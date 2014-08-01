socialDefaults =
  href: 'http://microplantstalk.zooniverse.org/'
  title: 'Microplants'
  summary: 'Help discover biodiversity!'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @FieldMuseum'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'leaf'
    projectName: 'Microplants'
    prefix: 'LF'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app

  developmentLocal:
    project: 'leaf'
    projectName: 'Microplants'
    prefix: 'LF'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app

  developmentRemote:
    project: 'leaf'
    projectName: 'Microplants'
    prefix: 'LF'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://demo.zooniverse.org/leaves/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app

  production:
    project: 'leaf'
    projectName: 'Microplants'
    prefix: 'LF'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://microplants.zooniverse.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-53428944-2'
      domain: 'http://microplantstalk.zooniverse.org'
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
