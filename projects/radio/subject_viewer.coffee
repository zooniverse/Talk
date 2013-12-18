DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'

$ = require 'jqueryify'

class RadioSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } radio-subject-viewer"
  template: template
  fitsImageDimension: 301

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

  drawContours: (contours) =>
    svg = d3.select(@el[0]).select('svg.svg-contours g.contours')

    if contours.contours?
      {contours, height, width} = contours
    xFactor = @width / (width || @fitsImageDimension)
    yFactor = @width / (height || @fitsImageDimension)
 
    path = d3.svg.line()
      .x( (d) -> xFactor * d.x)
      .y( (d) -> yFactor * d.y)
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
