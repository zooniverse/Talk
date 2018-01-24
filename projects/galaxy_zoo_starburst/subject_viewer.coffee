DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = window.jQuery

class GalaxyZooStarburstSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } galaxy-zoo-starburst-subject-viewer"
  template: template

module.exports = GalaxyZooStarburstSubjectViewer
