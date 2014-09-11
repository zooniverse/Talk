DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class ChicagoSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } chicago-subject-viewer"
  template: template

module.exports = ChicagoSubjectViewer
