SerengetiSubjectViewer = require 'controllers/serengeti_subject_viewer'

socialDefaults =
  href: 'http://talk.snapshotserengeti.org/'
  title: 'Snapshot Serengeti'
  summary: 'Classifying animal behavior on the Serengeti!'
  image: 'https://twimg0-a.akamaihd.net/profile_images/2794566694/dffbf19df47aadeaa1f96c744ae01bda.jpeg'
  twitterTags: 'via @snapserengeti'

Config =
  test:
    project: 'serengeti'
    prefix: 'SG'
    apiHost: null
    SubjectViewer: SerengetiSubjectViewer
    socialDefaults: socialDefaults
  
  developmentLocal:
    project: 'serengeti'
    prefix: 'SG'
    apiHost: 'http://localhost:3000'
    SubjectViewer: SerengetiSubjectViewer
    socialDefaults: socialDefaults

  developmentRemote:
    project: 'serengeti'
    prefix: 'SG'
    apiHost: 'https://dev.zooniverse.org'
    SubjectViewer: SerengetiSubjectViewer
    socialDefaults: socialDefaults

  production:
    project: 'serengeti'
    prefix: 'SG'
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
