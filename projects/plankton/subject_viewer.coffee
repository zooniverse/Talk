DefaultSubjectViewer = require 'controllers/default_subject_viewer'
ImageInspect = require 'cs-utils-imageinspect'
$ = require 'jqueryify'

class PlanktonSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } plankton-subject-viewer"
  template: require 'views/subjects/viewer'

  constructor: ->
    super
    new ImageInspect @el.find('img.main').get(0), {
      attachPoint: 'left top img.main 1.05 0'
    }

module.exports = PlanktonSubjectViewer
