DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class MilkyWaySubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } milky-way-subject-viewer"
  template: template

module.exports = MilkyWaySubjectViewer
