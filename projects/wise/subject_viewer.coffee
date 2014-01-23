DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class WiseSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } wise-subject-viewer"
  template: template

module.exports = WiseSubjectViewer
