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

    contours = (@subject.location.contours || @subject.location.contour)
    contours = contours.replace /^http:/, 'https:'
    $.getJSON contours, @drawContours if d3?

    $(window).on("resize", => @drawContours())

  onSliderChange: ({ target: { value } }) =>
    @infraredImage.css 'opacity', value

  drawContours: (contours) =>
    @elwidth = @el.width()
    @imageStack.height(@elwidth)
    @svg.height(@elwidth)

    svg = d3.select(@el[0]).select('svg.svg-contours')
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

  linkToFIRST: ->
    "http://third.ucllnl.org/cgi-bin/firstimage?RA=#{encodeURIComponent(@subject.metadata.ra_hms)}&Dec=#{encodeURIComponent("+" + @subject.metadata.dec_dms)}&Equinox=J2000&ImageSize=9&MaxInt=10"

  linkToSDSS: ->
    "http://skyserver.sdss3.org/public/en/tools/chart/navi.aspx?ra=#{@subject.coords[0]}&dec=#{@subject.coords[1]}&scale=0.2"

  linkToWISE: ->
    "http://irsa.ipac.caltech.edu/applications/wise/#id=Hydra_wise_wise_1&RequestClass=ServerRequest&DoSearch=true&intersect=CENTER&subsize=0.16666666800000002&mcenter=mcen&schema=allwise-multiband&dpLevel=3a&band=1,2,3,4&UserTargetWorldPt=#{@subject.coords[0]};#{@subject.coords[1]};EQ_J2000&SimpleTargetPanel.field.resolvedBy=nedthensimbad&preliminary_data=no&coaddId=&projectId=wise&searchName=wise_1&shortDesc=Position&isBookmarkAble=true&isDrillDownRoot=true&isSearchResult=true"

  linkToNVSS: ->
    "http://skyview.gsfc.nasa.gov/cgi-bin/images?Survey=nvss&position=#{@subject.coords.map((c) -> c.toFixed(3)).join(',')}&Pixels=300&Size=0.15&Return=GIF"

module.exports = RadioSubjectViewer
