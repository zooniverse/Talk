DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class FirstResponderSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } first-responder-subject-viewer"
  template: template

module.exports = FirstResponderSubjectViewer
