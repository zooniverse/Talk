DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class KelpSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } kelp-subject-viewer"
  template: template

  zoomLevel: 250000
  coordsReversed: true

  constructor: ->
    super
    for coord, i in @subject.coords
      @subject.coords[i] = coord.toFixed 5

    if @coordsReversed
      @subject.coords.reverse()

    setTimeout =>
      @render()

module.exports = KelpSubjectViewer
