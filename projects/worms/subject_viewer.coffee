DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require '../../views/subjects/viewer'
$ = window.jQuery

class WormSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } worms-subject-viewer"
  template: template

  constructor: ->
    super

    # I have no idea why this works
    videoObj.dispose() for id, videoObj of videojs.players

    videojs "worms-video"

module.exports = WormSubjectViewer
