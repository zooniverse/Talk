socialDefaults =
  href: 'http://talk.projectstardate.org/'
  title: 'Project Star Date'
  summary: 'Uncovering the ages of star clusters in the Southern Pinwheel Galaxy'
  image: 'http://www.projectstardate.org/resources/images/m83-cropped-520px.jpg'
  twitterTags: 'via @m83'

Config =
  test:
    project: 'm83'
    projectName: 'Project Star Date'
    prefix: 'M8'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'm83'
    projectName: 'Project Star Date'
    prefix: 'M8'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'm83'
    projectName: 'Project Star Date'
    prefix: 'M8'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/m83/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'm83'
    projectName: 'Project Star Date'
    prefix: 'M8'
    apiHost: 'http://www.projectstardate.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.projectstardate.org/#/classify'
    socialDefaults: socialDefaults
    analytics: {}

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
