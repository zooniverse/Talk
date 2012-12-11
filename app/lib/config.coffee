SerengetiSubjectViewer = require 'controllers/serengeti_subject_viewer'

socialDefaults =
  href: 'http://talk.snapshotserengeti.org/'
  title: 'Snapshot Serengeti'
  summary: 'Classifying animal behavior on the Serengeti!'
  image: 'https://twimg0-a.akamaihd.net/profile_images/2794566694/dffbf19df47aadeaa1f96c744ae01bda.jpeg'
  twitterTags: '#zooniverse @snapserengeti'

Config =
  test:
    project: 'serengeti'
    apiHost: null
    SubjectViewer: SerengetiSubjectViewer
    socialDefaults: socialDefaults
  
  developmentLocal:
    project: 'serengeti'
    apiHost: 'http://localhost:3000'
    SubjectViewer: SerengetiSubjectViewer
    socialDefaults: socialDefaults

  developmentRemote:
    project: 'serengeti'
    apiHost: 'https://dev.zooniverse.org'
    SubjectViewer: SerengetiSubjectViewer
    socialDefaults: socialDefaults

  production:
    project: 'serengeti'
    apiHost: 'https://api.zooniverse.org'
    SubjectViewer: SerengetiSubjectViewer
    socialDefaults: socialDefaults

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
