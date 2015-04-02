DefaultSubjectViewer = require 'controllers/default_subject_viewer'
$ = require 'jqueryify'

class ChimpSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } chimp-subject-viewer"
  template: require 'views/subjects/viewer'

  constructor: ->
    super
    
    videoObj.dispose() for id, videoObj of videojs.players
    videojs "worms-video"

module.exports = ChimpSubjectViewer
