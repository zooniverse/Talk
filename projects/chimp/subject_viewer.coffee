DefaultSubjectViewer = require 'controllers/default_subject_viewer'
$ = window.jQuery

class ChimpSubjectViewer extends DefaultSubjectViewer
  @imageIn: (location) -> location?.previews?[0]?[0] || 'http://placehold.it/300&text=video'

  className: "#{ DefaultSubjectViewer::className } chimp-subject-viewer"
  template: require 'views/subjects/viewer'

  constructor: ->
    super
    
    videoObj.dispose() for id, videoObj of videojs.players
    videojs "chimp-video"

module.exports = ChimpSubjectViewer
