socialDefaults =
  href: 'http://talk.sciencegossip.org/'
  title: 'Science Gossip'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @sciencegossip'

app =
  categoryLabels:
    science: 'research'
    chat: 'chat'
    help: 'help'
  roleLabels:
    scientist: 'researcher'

Config =
  test:
    project: 'illustratedlife'
    projectName: 'Science Gossip'
    prefix: 'SC'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'illustratedlife'
    projectName: 'Science Gossip'
    prefix: 'SC'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'illustratedlife'
    projectName: 'Science Gossip'
    prefix: 'SC'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://demo.zooniverse.org/bhl/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'illustratedlife'
    projectName: 'Science Gossip'
    prefix: 'SC'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.sciencegossip.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-'
      domain: 'http://talk.sciencegossip.org'
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
