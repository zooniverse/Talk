socialDefaults =
  href: 'http://talk.wardiary.org/'
  title: 'War Diaries'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @war_diary'

Config =
  test:
    project: 'war_diary'
    projectName: 'War Diaries'
    prefix: 'WD'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'war_diary'
    projectName: 'War Diaries'
    prefix: 'WD'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'war_diary'
    projectName: 'War Diaries'
    prefix: 'WD'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/diaries/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'war_diary'
    projectName: 'War Diaries'
    prefix: 'WD'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/diaries/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
      # account: 'UA-1234567-89'
      # domain: 'http://talk.wardiary.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]