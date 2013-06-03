DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class CycloneCenterSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } cyclone-center-subject-viewer"
  template: template
  
  @imageIn: (location) ->
    for key, url of location
      return url unless key.match(/yesterday$/)

module.exports = CycloneCenterSubjectViewer
