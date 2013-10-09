DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class WarDiarySubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } war-diary-subject-viewer"
  template: template

module.exports = WarDiarySubjectViewer
