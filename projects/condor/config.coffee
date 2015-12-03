socialDefaults =
  href: 'http://talk.condorwatch.org/'
  title: 'Condor Watch'
  summary: 'Track the location of the California Condor'
  image: 'http://www.condorwatch.org/images/nav-bg.jpg'
  twitterTags: 'via @condorwatch'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'condor'
    projectName: 'Condor Watch'
    prefix: 'CW'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'condor'
    projectName: 'Condor Watch'
    prefix: 'CW'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'condor'
    projectName: 'Condor Watch'
    prefix: 'CW'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.condorwatch.org/beta'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'condor'
    projectName: 'Condor Watch'
    prefix: 'CW'
    apiHost: 'http://www.condorwatch.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.condorwatch.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-54'
      domain: 'http://talk.condorwatch.org'
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
