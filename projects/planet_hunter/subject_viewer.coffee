{ Controller } = require 'spine'
$ = require 'jqueryify'
CanvasGraph = require 'lib/canvas-graph'

class PlanetHunterSubjectViewer extends Controller
  @imageIn: (location) -> location?.standard
  @subjectTitle: (subject) -> "Image #{ subject.zooniverse_id }"

  className: "subject-viewer planet-hunter-subject-viewer"
  template: require 'views/subjects/viewer'

  subject: null

  elements:
    'canvas': 'canvas'
    '.canvas-container': 'canvasContainer'

  events:
    'click .quarter': 'onClickQuarter'

  constructor: ->
    super

    @quarterList = Object.keys(@subject.location).sort (a, b) ->
      aQuarter = a.split '-'
      bQuarter = b.split '-'

      if aQuarter[0] is bQuarter[0]
        return aQuarter[1] - bQuarter[1]

      aQuarter[0] - bQuarter[0]

    params = location.search.slice(1).split('&')
    for param in params
      if param.indexOf('quarter') > 0
        @selectedQuarter = location.search.match /quarter=([\S]+)/

    @selectedQuarter ?= @quarterList[0]

    @html @template @
    @el.appendTo $('.page.focus.subject > header')

    setTimeout =>
      $("[data-quarter=\"#{ @selectedQuarter }\"]").click()

  onClickQuarter: (e) =>
    spinner = new Spinner({width: 3, color: '#fff'}).spin @canvasContainer.get(0)

    $("[data-quarter]").removeClass 'active'

    @selectedQuarter = $(e.currentTarget).data 'quarter'

    $("[data-quarter=\"#{ @selectedQuarter }\"]").addClass 'active'
    $.getJSON "#{ @subject.location[@selectedQuarter] }", (data) =>
      spinner.stop()
      @graph = new CanvasGraph @el, @canvas.get(0), data

module.exports = PlanetHunterSubjectViewer
