DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = window.jQuery

class CondorSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } condor-subject-viewer"
  template: template

module.exports = CondorSubjectViewer
