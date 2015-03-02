DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class IllustratedlifeSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } illustratedlife-subject-viewer"
  template: template

module.exports = IllustratedlifeSubjectViewer
