socialDefaults =
  href: 'http://talk.operationwardiary.org/'
  title: 'Operation War Diary'
  summary: 'The story of the British Army on the Western Front during the First World War is waiting to be discovered in 1.5 million pages of unit war diaries.'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @war_diary'

Config =
  test:
    project: 'war_diary'
    projectName: 'Operation War Diary'
    prefix: 'WD'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'war_diary'
    projectName: 'Operation War Diary'
    prefix: 'WD'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'war_diary'
    projectName: 'Operation War Diary'
    prefix: 'WD'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/war_diary/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'war_diary'
    projectName: 'Operation War Diary'
    prefix: 'WD'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.operationwardiary.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-51'
      domain: 'http://talk.operationwardiary.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
