DefaultSubjectViewer = require 'controllers/default_subject_viewer'

Config =
  test:
    project: 'serengeti'
    apiHost: null
    SubjectViewer: DefaultSubjectViewer
  
  developmentLocal:
    project: 'serengeti'
    apiHost: 'http://localhost:3000'
    SubjectViewer: DefaultSubjectViewer
  
  developmentRemote:
    project: 'serengeti'
    apiHost: 'https://dev.zooniverse.org'
    SubjectViewer: DefaultSubjectViewer
  
  production:
    project: 'serengeti'
    apiHost: 'https://dev.zooniverse.org'
    SubjectViewer: DefaultSubjectViewer

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
