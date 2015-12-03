socialDefaults =
  href: 'http://talk.notesfromnature.org/'
  title: 'Notes From Nature'
  summary: 'Transcribing in Notes from Nature'
  image: 'https://si0.twimg.com/profile_images/3468070736/662c1dbc17f7f5e91dd91a2ad0bd9bef.jpeg'
  twitterTags: 'via @nfromn'

Config =
  test:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/archives'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.notesfromnature.org/beta/#/archives'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: 'http://www.notesfromnature.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.notesfromnature.org/#/archives'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.notesfromnature.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
