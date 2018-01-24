DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = window.jQuery

class SpacewarpSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } spacewarp-subject-viewer"
  template: template

module.exports = SpacewarpSubjectViewer
