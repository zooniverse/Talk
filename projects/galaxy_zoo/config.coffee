socialDefaults =
  href: 'http://talk.galaxyzoo.org/'
  title: 'Galaxy Zoo'
  summary: 'Classifying galaxies in the distant universe!'
  image: 'https://si0.twimg.com/profile_images/2597266958/image.jpg'
  twitterTags: 'via @galaxyzoo'

Config =
  test:
    project: 'galaxy_zoo'
    projectName: 'Galaxy Zoo'
    prefix: 'GZ'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'galaxy_zoo'
    projectName: 'Galaxy Zoo'
    prefix: 'GZ'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'galaxy_zoo'
    projectName: 'Galaxy Zoo'
    prefix: 'GZ'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/galaxy_zoo/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'galaxy_zoo'
    projectName: 'Galaxy Zoo'
    prefix: 'GZ'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.galaxyzoo.org/#/classify'
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
