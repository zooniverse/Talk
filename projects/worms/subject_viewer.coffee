DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class WormSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } worms-subject-viewer"
  template: template

  constructor: ->
    super

    videojs "worms_video", ->
      # nothing

module.exports = WormSubjectViewer
