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

  events:
    'input .image-slider' : 'onSliderChange'

  constructor: ->
    super

    contours = @subject.location.contours || @subject.location.contour
    $.getJSON contours, @drawContours if d3?

    $(window).on("resize", => @drawContours())

  onSliderChange: ({ target: { value } }) =>
    @infraredImage.css 'opacity', value

  drawContours: (contours) =>
    @elwidth = @el.width()
    @imageStack.height(@elwidth)
    @svg.height(@elwidth)

    svg = d3.select('svg.svg-contours')
      .append('g').attr('class', 'contours')

    d3.selectAll('path').remove()

    if contours?.contours?
      {@contours, @height, @width} = contours
    else if contours?
      @contours = contours
    xFactor = @elwidth / (@width || @fitsImageDimension)
    yFactor = @elwidth / (@height || @fitsImageDimension)
 
    path = d3.svg.line()
      .x( (d) -> xFactor * d.x)
      .y( (d) -> yFactor * d.y)
      .interpolate('linear')
    
    cGroups = svg.selectAll('g.contour-group')
      .data(@contours)

    paths = cGroups.enter().append('g')
      .attr('id', (d, i) -> i)
      .selectAll('path').data((d) -> d)

    cGroups.attr('class', (d, i) -> 'contour-group')

    paths.enter().append('path')
      .attr('class', 'svg-contour')
      .attr('d', (d) -> path(d['arr']))

    paths.exit().remove()

    cGroups.exit().remove()

module.exports = RadioSubjectViewer
