SerengetiSubjectViewer = require 'controllers/serengeti_subject_viewer'

Config =
  test:
    project: 'serengeti'
    apiHost: null
    SubjectViewer: SerengetiSubjectViewer
  
  developmentLocal:
    project: 'serengeti'
    apiHost: 'http://localhost:3000'
    SubjectViewer: SerengetiSubjectViewer
  
  developmentRemote:
    project: 'serengeti'
    apiHost: 'https://dev.zooniverse.org'
    SubjectViewer: SerengetiSubjectViewer
  
  production:
    project: 'serengeti'
    apiHost: 'https://dev.zooniverse.org'
    SubjectViewer: SerengetiSubjectViewer

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
