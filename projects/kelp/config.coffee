socialDefaults =
  href: 'http://talk.floatingforests.org/'
  title: 'Floating Forests'
  summary: 'Discover Floating Forests!'
  image: 'http://www.floatingforests.org/images/kelp-forest-large.jpg'
  twitterTags: 'via @floatingforests'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'kelp'
    projectName: 'Floating Forests'
    prefix: 'KP'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'kelp'
    projectName: 'Floating Forests'
    prefix: 'KP'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'kelp'
    projectName: 'Floating Forests'
    prefix: 'KP'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://demo.zooniverse.org/kelp/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'kelp'
    projectName: 'Floating Forests'
    prefix: 'KP'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.floatingforests.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-59'
      domain: 'http://talk.floatingforests.org'
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
