DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class OrchidSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } orchid-subject-viewer"
  template: template

module.exports = OrchidSubjectViewer
