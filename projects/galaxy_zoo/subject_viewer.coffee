DefaultSubjectViewer = require './default_subject_viewer'
$ = window.jQuery

class GalaxyZooSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } galaxy-zoo-subject-viewer"
  template: require '../views/subjects/viewer'

module.exports = GalaxyZooSubjectViewer
