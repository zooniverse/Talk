socialDefaults =
  href: 'http://talk.milkywayproject.org/'
  title: 'The Milky Way Project'
  summary: 'Mapping our galaxy in The Milky Way Project'
  image: 'https://pbs.twimg.com/profile_images/2680176697/cc42ff750e4c1e61fe240246e5af87f3.png'
  twitterTags: 'via @milkywayproj'

Config =
  test:
    project: 'milky_way'
    projectName: 'The Milky Way Project'
    prefix: 'MW'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }

  developmentLocal:
    project: 'milky_way'
    projectName: 'The Milky Way Project'
    prefix: 'MW'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/classify'
    socialDefaults: socialDefaults
    analytics: { }

  developmentRemote:
    project: 'milky_way'
    projectName: 'The Milky Way Project'
    prefix: 'MW'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://demo.zooniverse.org/milky-way-project/#/classify'
    socialDefaults: socialDefaults
    analytics: { }

  production:
    project: 'milky_way'
    projectName: 'The Milky Way Project'
    prefix: 'MW'
    apiHost: 'https://www.milkywayproject.org'
    apiPath: '/_ouroboros_api/proxy'
    classifyUrl: 'http://www.milkywayproject.org/#/classify'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1224199-24'
      domain: 'talk.milkywayproject.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024
  'developmentRemote'
else
  'production'

module.exports = Config[env]
