DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = window.jQuery

class M83SubjectViewer extends DefaultSubjectViewer
  @subjectTitle: (subject) ->
    { file_name } = subject.metadata
    if file_name? then "Image #{ file_name }" else super

  className: "#{ DefaultSubjectViewer::className } m83-subject-viewer"
  template: template

module.exports = M83SubjectViewer
