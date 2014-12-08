DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class WisconsinSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } wisconsin-subject-viewer"
  template: template

module.exports = WisconsinSubjectViewer
