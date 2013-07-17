socialDefaults =
  href: 'http://quench-talk.galaxyzoo.org/'
  title: 'Quench Galaxy Zoo'
  summary: 'Take part in science from start to end.'
  image: 'https://si0.twimg.com/profile_images/2597266958/image.jpg'
  twitterTags: 'via @galaxyzoo'

Config =
  test:
    project: 'galaxy_zoo_starburst'
    projectName: 'Galaxy Zoo Quench'
    prefix: 'GS'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'galaxy_zoo_starburst'
    projectName: 'Galaxy Zoo Quench'
    prefix: 'GS'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'galaxy_zoo_starburst'
    projectName: 'Galaxy Zoo Quench'
    prefix: 'GS'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://quench.galaxyzoo.org/galaxy_zoo_starburst/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'galaxy_zoo_starburst'
    projectName: 'Galaxy Zoo Quench'
    prefix: 'GS'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://quench.galaxyzoo.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-9'
      domain: 'talk.galaxyzoo.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'
  
module.exports = Config[env]
