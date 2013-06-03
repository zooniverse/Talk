socialDefaults =
  href: 'http://talk.cyclonecenter.org/'
  title: 'Cyclone Center'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @cyclone_center'

Config =
  test:
    project: 'cyclone_center'
    projectName: 'Cyclone Center'
    prefix: 'CC'
    grouped: true
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'cyclone_center'
    projectName: 'Cyclone Center'
    prefix: 'CC'
    grouped: true
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'cyclone_center'
    projectName: 'Cyclone Center'
    prefix: 'CC'
    grouped: true
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/cyclone_center/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'cyclone_center'
    projectName: 'Cyclone Center'
    prefix: 'CC'
    grouped: true
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.cyclonecenter.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.cyclonecenter.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
