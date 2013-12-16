DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class RadioSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } radio-subject-viewer"
  template: template

  elements:
    '.main': 'infraredImage'
    '.radio': 'radioImage'

  constructor: ->
    super

    slider = document.querySelector ".image-slider"
    slider.addEventListener 'change', @onSliderChange

  onSliderChange: ({ target: { value } }) =>
    @infraredImage.css 'opacity', 1 - value
    @radioImage.css 'opacity', value

module.exports = RadioSubjectViewer
