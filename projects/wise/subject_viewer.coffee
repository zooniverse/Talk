DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

wavelengthKeys = 
  'sdssu': 'SDSS U 0.359 μm)'
  'sdssg': 'SDSS G 0.481 μm)'
  'sdssr': 'SDSS R 0.623 μm)'
  'sdssi': 'SDSS I 0.764 μm)'
  'sdssz': 'SDSS Z 0.906 μm)'
  'dss2blue': 'DSS2 Blue (0.665 μm)'
  'dss2red': 'DSS2 Red (0.975 μm)'
  'dss2ir': 'DSS2 IR (1.15 μm)'
  '2massj': '2MASS J (1.24 μm)'
  '2massh': '2MASS H (1.66 μm)'
  '2massk' : '2MASS K (2.16 μm)'
  'wise1' : 'WISE 1 (3.4 μm)'
  'wise2' : 'WISE 2 (4.6 μm)'
  'wise3' : 'WISE 3 (12 μm)'
  'wise4' : 'WISE 4 (22 μm)'

class IVModel extends Backbone.Model
  wavelengths: [
    'sdssu',
    'sdssg',
    'sdssr',
    'sdssi',
    'sdssz',
    'dss2blue',
    'dss2red',
    'dss2ir',
    '2massj',
    '2massh',
    '2massk',
    'wise1',
    'wise2',
    'wise3',
    'wise4'
  ]

  defaults: {
    index: 0
    animate: false
    loop: false
    images: []
  }

  preloadImages: (subject) =>
    loadedImages = 0
    promise = new $.Deferred()
    
    locs = @subjectWavelengths(subject)
    inc = =>
      loadedImages = loadedImages + 1
      if (loadedImages is locs.length)
        promise.resolve()

    imgs = _.map(locs, (source) ->
      img = new Image
      img.src = source.src
      img.onload = inc
      {img: img, wavelength: source.wavelength})

    @set('max', imgs.length)
    @set('images', imgs)

    return promise

  subjectWavelengths: (subject) =>
    srcs = _.chain(@wavelengths)
      .filter((w) -> subject.location[w]?)
      .map((w) -> {src: subject.location[w], wavelength: w})
      .value()
       
    if _.find(srcs, (s) -> s.wavelength is 'sdssu')
      srcs = _.filter(srcs, (s) -> 
        not (s.wavelength in ['dss2blue', 'dss2red', 'dss2ir']))

    srcs

  isPlaying: ->
    @get('animate')

  play: ->
    @set('index', 0) if @get('index') + 1 is @get('images').length
    setTimeout((=> @set('animate', true)), 500)

  pause: ->
    @set('animate', false)

  currentImage: ->
    @get('images')[@get('index')]

  decrementIndex: ->
    i = @get('index') - 1
    l = @get('loop')
    max = @get('max') - 1

    if i < 0
      unless l
        @set('animate', false) 
        i = 0
      else
        i = max

    @set('index', i) 

  incrementIndex: ->
    i = @get('index') + 1
    l = @get('loop')
    max = @get('max') - 1

    if i > max
      unless l
        @set('animate', false) 
        i = i - 1
      else
        i = 0

    @set('index', i) 

  reset: ->
    _.each(@defaults, ((v, k) -> @set(k, v)), @)

  toggleLoop: ->
    @set('loop', not @get('loop'))

class Timeline extends Backbone.View
  el: '#timeline'
  wavelengths: wavelengthKeys

  initialize: ->
    @listenTo(@model, "change:index", @updateTimeline)
    @range = @$('input')
    @currentWavelength = @$('p:NOT(.pull-left, .pull-right)')
    @updateTimeline(@model, @model.get('index'))

  events:
    'mousedown input' : 'startScrub'
    'touchdown input' : 'startScrub'

  updateTimeline: (m, index) ->
    max = m.get('max')
    if parseInt(@range.attr('max')) isnt max
      @range.attr('max', max - 1)
    @range.val(index)
    @currentWavelength.text(@wavelengths[m.currentImage()?.wavelength])

  startScrub: =>
    if parseInt(@range.val()) isnt @model.get('index')
      @model.set('index', parseInt(@range.val()))
    @$el.on('mousemove', @scrub)
    @$el.on('mosueup', @endScrub)
    @$el.on('touchmove', @scrub)
    @$el.on('touchup', @endScrub)

  endScrub: =>
    @$el.off('mousemove')
    @$el.off('mouseup')
    @$el.off('touchmove')
    @$el.off('touchup')

  scrub: =>
    @model.set('index', parseInt(@range.val()))

class Overlay extends Backbone.View
  el: 'canvas'

  initialize: ->
    @ctx = @el.getContext('2d')
    @ctx.lineWidth = 2
    @ctx.strokeStyle = 'red'
    @center = {x: @el.width / 2, y: @el.height / 2}

  circleRadius: 70
  crosshairRadius: 7

  drawCrosshair: =>
    @ctx.beginPath()
    @ctx.moveTo(@center.x - @crosshairRadius, @center.y)
    @ctx.lineTo(@center.x + @crosshairRadius, @center.y)
    @ctx.closePath()
    @ctx.stroke()
    @ctx.beginPath()
    @ctx.moveTo(@center.x, @center.y - @crosshairRadius)
    @ctx.lineTo(@center.x, @center.y + @crosshairRadius)
    @ctx.closePath()
    @ctx.stroke()

  drawCircle: =>
    @ctx.beginPath()
    @ctx.arc(@center.x, @center.y, @circleRadius, 0, Math.PI*2, true)
    @ctx.closePath()
    @ctx.stroke()

  wavelength: (wavelength) =>
    @drawCrosshair()
    @drawCircle()

class Controls extends Backbone.View
  template: -> 
    """
<button class="btn circular play" title="Play">
  <img src="img/play.svg" onerror="this.src='img/play.png'">
</button>
<button class="btn circular pause" title="Pause">
  <img src="img/pause.svg" onerror="this.src='img/pause.png'">
</button>
<button class="btn circular loop" title="Toggle Loop">
  <img src="img/loop.svg" onerror="this.src='img/loop.png'">
</button>
    """
  initialize: ->
    @listenTo(@model, "change:animate", @reset)

  events:
    'click .play': 'play'
    'click .pause' : 'pause'
    'click .loop' : 'toggleLoop'

  reset: (m, a) ->
    unless a
      @$('.play').show()
      @$('.pause').hide()

  play: (e) ->
    @$('.play').hide()
    @$('.pause').show()
    @model.play()

  pause: (e) ->
    @$('.pause').hide()
    @$('.play').show()
    @model.pause()

  toggleLoop: (e) ->
    @$('.loop').toggleClass('active')
    @model.toggleLoop()

  render: ->
    @$el.append(@template())
    @

class ImageViewer extends Backbone.View
  initialize: (opts) ->
    @setupCanvas()

    @model = new IVModel()

    if opts.controls
      @controls = new Controls({model: @model, el: @el})
      @controls.render()

    if opts.timeline
      @timeline = new Timeline({model: @model})

    @overlay = new Overlay({model: @model, el: @canvas})

    @listenTo(@model, 'change:animate', @animate)

  setupCanvas: ->
    @canvas = @$('canvas')[0]
    @ctx = @canvas.getContext('2d')

  drawImage: =>
    {img, wavelength} = @model.currentImage()

    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    @ctx.drawImage(img, 0, 0, @canvas.width, @canvas.height)
    @overlay.wavelength(wavelength)

  animate: =>
    if @model.isPlaying()
      @model.incrementIndex()
      setTimeout(@animate, 500)

  setupSubject: (subject) =>
    return if !subject
    @stopListening(@model, 'change:index', @drawImage)
    @model.reset()
    @model.preloadImages(subject).then(@postloadImages)

  postloadImages: =>
    @$('.loading').hide()
    if @timeline?
      @timeline.updateTimeline(@model, @model.get('index'))
    @drawImage()
    @listenTo(@model, 'change:index', @drawImage)


class WiseSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } wise-subject-viewer"
  template: template

module.exports = WiseSubjectViewer
