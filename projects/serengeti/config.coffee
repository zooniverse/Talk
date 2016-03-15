socialDefaults =
  href: 'http://talk.snapshotserengeti.org/'
  title: 'Snapshot Serengeti'
  summary: 'Classifying animal behavior on the Serengeti!'
  image: 'https://twimg0-a.akamaihd.net/profile_images/2794566694/dffbf19df47aadeaa1f96c744ae01bda.jpeg'
  twitterTags: 'via @snapserengeti'

Config =
  test:
    project: 'serengeti'
    projectName: 'Snapshot Serengeti'
    prefix: 'SG'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }

  developmentLocal:
    project: 'serengeti'
    projectName: 'Snapshot Serengeti'
    prefix: 'SG'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }

  developmentRemote:
    project: 'serengeti'
    projectName: 'Snapshot Serengeti'
    prefix: 'SG'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/serengeti/#/classify'
    socialDefaults: socialDefaults
    analytics: { }

  production:
    project: 'serengeti'
    projectName: 'Snapshot Serengeti'
    prefix: 'SG'
    apiHost: 'https://www.snapshotserengeti.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.snapshotserengeti.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-36'
      domain: 'snapshotserengeti.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024
  'developmentRemote'
else
  'production'

module.exports = Config[env]
