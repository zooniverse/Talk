DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class LeafSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } leaf-subject-viewer"
  template: template

module.exports = LeafSubjectViewer
