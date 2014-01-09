DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class M83SubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } m83-subject-viewer"
  template: template

module.exports = M83SubjectViewer
