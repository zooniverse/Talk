DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class PlanetFourSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } planet-four-subject-viewer"
  template: template


module.exports = PlanetFourSubjectViewer
