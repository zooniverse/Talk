socialDefaults =
  href: 'http://talk.orchidobservers.org/'
  title: 'Orchid Observers'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @orchid'

app =
  categories: ['help', 'science', 'chat']

Config =
  test:
    project: 'orchid'
    projectName: 'Orchid Observers'
    prefix: 'ZO'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
    app: app

  developmentLocal:
    project: 'orchid'
    projectName: 'Orchid Observers'
    prefix: 'ZO'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }
    app: app

  developmentRemote:
    project: 'orchid'
    projectName: 'Orchid Observers'
    prefix: 'ZO'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://preview.zooniverse.org/orchids/#/transcribe'
    socialDefaults: socialDefaults
    analytics: { }
    app: app

  production:
    project: 'orchid'
    projectName: 'Orchid Observers'
    prefix: 'ZO'
    apiHost: 'https://www.orchidobservers.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.orchidobservers.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-17'
      domain: 'http://talk.orchidobservers.org'
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
