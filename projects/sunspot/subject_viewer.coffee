DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

loadImage = (src, cb) ->
  image = new Image
  image.onload = ->
    cb image if cb?
  image.src = src

class SunspotSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } sunspot-subject-viewer"
  template: template

  viewing: false

  elements:
    'img.context': 'subjectContextImage'
    '.large-mouseover': 'largeImageContainer'
    '.subject-images': 'subjectImages'

  events:
    'mouseover img': 'onMouseOver'
    'click button.action': 'onClickAction'

  constructor: ->
    super

    @largeImageContainer.css
      "background-image": "url(\"#{ @subject.location.context }\")"

    loadImage @subject.location.standard, (@standardImage) =>
      @standardImage.className = 'standard-image targets'
      @standardImage = $(@standardImage)
      @subjectImages.append @standardImage

    loadImage @subject.location.inverted, (@invertedImage) =>
      @invertedImage.className = 'inverted-image targets'
      @invertedImage.style.display = 'none'
      @invertedImage = $(@invertedImage)
      @subjectImages.append @invertedImage

    loadImage @subject.location.context, (@contextImage) =>
      @contextImage.className = 'context-image targets hoverable'
      @contextImage.style.display = 'none'
      @contextImage = $(@contextImage)
      @subjectImages.append @contextImage

  onClickAction: (e) =>
    view = @el.get 0
    { target } = e.currentTarget.dataset

    hideThese = Array::slice.call view.querySelectorAll('.targets'), 0
    element.style.display = 'none' for element in hideThese

    showThese = Array::slice.call view.querySelectorAll(".#{ target }"), 0
    element.style.display = 'block' for element in showThese

  onMouseOver: (e) =>
    return unless $(e.currentTarget).hasClass 'hoverable'

    @height = @el.get(0).clientHeight
    @width = @el.get(0).clientWidth
    @widthRatio = @contextImage.get(0).naturalWidth / @width
    @heightRatio = @contextImage.get(0).naturalHeight / @height

    @viewing = true
    @largeImageContainer.css
      'display': 'block'
      'max-width': @contextImage.get(0).naturalWidth
    @contextImage.on 'mouseout.viewer', @onMouseOut

    box = [@width * 0.33, @height * 0.33]

    @contextImage.on 'mousemove.viewer', (mm_e) =>
      if @viewing
        offsetX = mm_e.pageX - @contextImage.parent().offset().left
        offsetY = mm_e.pageY - @contextImage.parent().offset().top

        position = [(offsetX - (box[0] / 2)) * @widthRatio, ((offsetY - (box[1] / 2)) * @heightRatio)]
        position = (for axis in position then parseInt(Math.max(axis, 0)))

        if position[0] + @largeImageContainer.width() > @contextImage.get(0).naturalWidth
          position[0] = @contextImage.get(0).naturalWidth - @largeImageContainer.width()

        if position[1] + @largeImageContainer.height() > @contextImage.get(0).naturalHeight
          position[1] = @contextImage.get(0).naturalHeight - @largeImageContainer.height()

        @largeImageContainer.css
          "background-position": "-#{position[0]}px -#{position[1]}px"

  onMouseOut: (e) =>
    @contextImage.off 'mousemove.viewer, mouseout.viewer'
    @viewing = false
    @largeImageContainer.css 'display', 'none'


module.exports = SunspotSubjectViewer
