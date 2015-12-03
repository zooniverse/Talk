socialDefaults =
  href: 'http://talk.diskdetective.org/'
  title: 'Disk Detective'
  summary: 'Comb our galaxy looking for stars that could be harbouring planet-forming disks'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @disk_detective'

Config =
  test:
    project: 'wise'
    projectName: 'Disk Detective'
    prefix: 'WI'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    subjectViewerDiscuss: true
  
  developmentLocal:
    project: 'wise'
    projectName: 'Disk Detective'
    prefix: 'WI'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
  
  developmentRemote:
    project: 'wise'
    projectName: 'Disk Detective'
    prefix: 'WI'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/wise/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }
  
  production:
    project: 'wise'
    projectName: 'Disk Detective'
    prefix: 'WI'
    apiHost: 'http://www.diskdetective.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.diskdetective.org/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics:
      account: 'UA-1224199-50'
      domain: 'http://talk.diskdetective.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
