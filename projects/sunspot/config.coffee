socialDefaults =
  href: 'http://talk.sunspotter.org/'
  title: 'Sunspotter'
  summary: "Help us organize sunspot images in order of complexity to better understand and predict how the Sun's magnetic activity affects us on Earth."
  image: 'http://www.sunspotter.org/images/science/sunspot_size.jpg'
  twitterTags: 'via @sun_spotter'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'sunspot'
    projectName: 'Sunspotter'
    prefix: 'SZ'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'sunspot'
    projectName: 'Sunspotter'
    prefix: 'SZ'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'sunspot'
    projectName: 'Sunspotter'
    prefix: 'SZ'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.sunspotter.org/beta/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'sunspot'
    projectName: 'Sunspotter'
    prefix: 'SZ'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.sunspotter.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.sunspotter.org'
    app: app

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
