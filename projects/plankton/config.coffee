socialDefaults =
  href: 'http://talk.planktonportal.org/'
  title: 'Plankton'
  summary: 'Inspecting diversity of plankton species!'
  image: 'https://twimg0-a.akamaihd.net/profile_images/378800000187643583/58bf1212a6702a38b358399164d27a2c.jpeg'
  twitterTags: 'via @PlanktonPortal'

Config =
  test:
    project: 'plankton'
    projectName: 'Plankton Portal'
    prefix: 'PK'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }

  developmentLocal:
    project: 'plankton'
    projectName: 'Plankton Portal'
    prefix: 'PK'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }

  developmentRemote:
    project: 'plankton'
    projectName: 'Plankton Portal'
    prefix: 'PK'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.planktonportal.org/beta/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics: { }

  production:
    project: 'plankton'
    projectName: 'Plankton Portal'
    prefix: 'PK'
    apiHost: 'https://www.planktonportal.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.planktonportal.org/#/classify'
    socialDefaults: socialDefaults
    subjectViewerDiscuss: true
    analytics:
      account: 'UA-1224199-45'
      domain: 'http://talk.planktonportal.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024
  'developmentRemote'
else
  'production'

module.exports = Config[env]
