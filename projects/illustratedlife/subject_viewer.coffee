DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = window.jQuery

class IllustratedlifeSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } illustratedlife-subject-viewer"
  template: template

module.exports = IllustratedlifeSubjectViewer
