DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class WormSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } worms-subject-viewer"
  template: template

module.exports = WormSubjectViewer
