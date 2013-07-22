DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class PlanktonSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } plankton-subject-viewer"
  template: template

module.exports = PlanktonSubjectViewer
