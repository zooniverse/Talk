socialDefaults =
  href: 'http://talk.planetfour.org/'
  title: 'Planet Four'
  summary: 'Identifying features on the surface of the Red Planet!'
  image: 'https://twimg0-a.akamaihd.net/profile_images/3034609545/b3f45aa65d77590ea91a3f6286fa28c9.jpeg'
  twitterTags: 'via @planet_four'

Config =
  test:
    project: 'planet_four'
    projectName: 'Planet Four'
    prefix: 'PF'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'planet_four'
    projectName: 'Planet Four'
    prefix: 'PF'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }

  developmentRemote:
    project: 'planet_four'
    projectName: 'Planet Four'
    prefix: 'PF'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://zooniverse-demo.s3-website-us-east-1.amazonaws.com/mars/#/classify'
    socialDefaults: socialDefaults
    analytics: { }

  production:
    project: 'planet_four'
    projectName: 'Planet Four'
    prefix: 'PF'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.planetfour.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-41'
      domain: 'talk.planetfour.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
