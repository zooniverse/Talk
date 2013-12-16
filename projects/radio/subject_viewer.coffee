DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'

$ = require 'jqueryify'

FITS_DIMENSION = 301

class RadioSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } radio-subject-viewer"
  template: template

  elements:
    '.main': 'infraredImage'
    '.radio': 'radioImage'

  constructor: ->
    super

    @width = @el.width()

    $('.image-stack').height @width

    $.getJSON @subject.location.contour, @drawContours if d3?

    slider = document.querySelector '.image-slider'
    slider.addEventListener 'input', @onSliderChange

  onSliderChange: ({ target: { value } }) =>
    @infraredImage.css 'opacity', 1 - value
    @radioImage.css 'opacity', value

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
