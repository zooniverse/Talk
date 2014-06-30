DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class PenguinSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } penguin-subject-viewer"
  template: template

module.exports = PenguinSubjectViewer
