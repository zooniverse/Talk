DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require '../../views/subjects/viewer'
$ = window.jQuery

class OrchidSubjectViewer extends DefaultSubjectViewer
  @imageIn: (location) -> 
    if Array.isArray location.standard
      return location.standard[0]
    else
      return location.standard
  
  className: "#{ DefaultSubjectViewer::className } orchid-subject-viewer"
  template: template

module.exports = OrchidSubjectViewer
