socialDefaults =
  href: 'http://talk.spacewarp.org/'
  title: 'Spacewarps'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @spacewarp'

Config =
  test:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/spacewarp/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'spacewarp'
    projectName: 'Spacewarps'
    prefix: 'SW'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.spacewarp.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.spacewarp.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
