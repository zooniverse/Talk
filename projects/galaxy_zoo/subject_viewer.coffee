DefaultSubjectViewer = require './default_subject_viewer'
template = require '../views/subjects/viewer'
$ = window.jQuery

class GalaxyZooSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } galaxy-zoo-subject-viewer"
  template: template

module.exports = GalaxyZooSubjectViewer
