DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'

$ = require 'jqueryify'

FITS_DIMENSION = 301

class RadioSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } radio-subject-viewer"
  template: template

  elements:
    '.image-stack': 'imageStack'
    '.main': 'infraredImage'
    '.radio': 'radioImage'
    'svg': 'svg'

  constructor: ->
    super

    @width = @el.width()

    @imageStack.height @width
    @svg.height @width

    contours = @subject.location.contours || @subject.location.contour
    $.getJSON contours, @drawContours if d3?

    slider = document.querySelector '.image-slider'
    slider.addEventListener 'input', @onSliderChange

  onSliderChange: ({ target: { value } }) =>
    @infraredImage.css 'opacity', value
    @radioImage.css 'opacity', 1 - value

  drawContours: (contours) =>
    svg = d3.select('svg.svg-contours g.contours')
    factor = @width / FITS_DIMENSION
    path = d3.svg.line()
      .x( (d) -> factor * d.x)
      .y( (d) -> factor * d.y)
      .interpolate('linear')

    cGroups = svg.selectAll('g.contour-group')
      .data(contours)

    cGroups.enter().append('g')
      .attr('id', (d, i) -> i)

    cGroups.attr 'class', (d, i) -> 'contour-group'
    
    paths = cGroups.selectAll('path').data((d) -> d)

    paths.enter().append('path')
      .attr('d', (d) -> path(d['arr']))
      .attr('class', 'svg-contour')

    cGroups.exit().remove()

module.exports = RadioSubjectViewer
