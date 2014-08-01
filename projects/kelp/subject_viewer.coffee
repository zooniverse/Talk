DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class KelpSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } kelp-subject-viewer"
  template: template

module.exports = KelpSubjectViewer
