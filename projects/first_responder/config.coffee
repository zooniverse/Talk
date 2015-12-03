socialDefaults =
  href: 'http://talk.planetaryresponsenetwork.com/'
  title: 'First Responders'
  summary: 'Join the relief effort to help crisis victims'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @first_responder'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'first_responder'
    projectName: 'First Responders'
    prefix: 'FR'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentLocal:
    project: 'first_responder'
    projectName: 'First Responders'
    prefix: 'FR'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  developmentRemote:
    project: 'first_responder'
    projectName: 'First Responders'
    prefix: 'FR'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.planetaryresponsenetwork.com/beta/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app
  
  production:
    project: 'first_responder'
    projectName: 'First Responders'
    prefix: 'FR'
    apiHost: 'http://www.planetaryresponsenetwork.com'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.planetaryresponsenetwork.com/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-53428944-6'
      domain: 'http://talk.planetaryresponsenetwork.com'
    app: app

# env = if window.jasmine
#   'test'
# else if window.location.port is '9295'
#   'developmentLocal'
# else if window.location.port > 1024 
#   'developmentRemote'
# else
#   'production'

module.exports = Config['developmentRemote']
