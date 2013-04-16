DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class NotesFromNatureSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } notes-from-nature-subject-viewer"
  template: template

module.exports = NotesFromNatureSubjectViewer
