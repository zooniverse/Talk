DefaultSubjectViewer = require 'controllers/default_subject_viewer'
$ = require 'jqueryify'

loadImage = (src, cb) ->
  image = new Image
  image.onload = ->
    cb image if cb?
  image.src = src

names = ['first', 'second', 'third']

class HiggsHunterSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } higgs-hunter-subject-viewer"
  template: require 'views/subjects/viewer'

  viewing: false
  images: []

  elements:
    '.large-mouseover': 'largeImageContainer'
    '.subject-images img': 'subjectImages'

  events:
    'mouseover img': 'onMouseOver'
    'click button.action': 'onClickAction'

  constructor: ->
    super

    @largeImageContainer.css
      "background-image": "url(\"#{ @subject.location.standard[0] }\")"

    @subjectImages.first().show()

  onClickAction: (e) =>
    view = @el.get 0
    target = $(e.currentTarget).data('target')

    @subjectImages.hide()
    @subjectImages.filter("[data-target=\"#{ +target }\"]").show()

  onMouseOver: (e) =>
    image = @currentImage = $(@subjectImages.get $(e.currentTarget).data('target'))

    @height = @el.get(0).clientHeight
    @width = @el.get(0).clientWidth
    @widthRatio = image.get(0).naturalWidth / @width
    @heightRatio = image.get(0).naturalHeight / @height

    @viewing = true
    @largeImageContainer.css
      'display': 'block'
      'max-width': image.get(0).naturalWidth
      'background-image': "url(#{ image.attr('src') })"

    image.on 'mouseout.viewer', @onMouseOut

    box = [@width * 0.33, @height * 0.33]

    image.on 'mousemove.viewer', (mm_e) =>
      if @viewing
        offsetX = mm_e.pageX - image.parent().offset().left
        offsetY = mm_e.pageY - image.parent().offset().top

        position = [(offsetX - (box[0] / 2)) * @widthRatio, ((offsetY - (box[1] / 2)) * @heightRatio)]
        position = (for axis in position then parseInt(Math.max(axis, 0)))

        if position[0] + @largeImageContainer.width() > image.get(0).naturalWidth
          position[0] = image.get(0).naturalWidth - @largeImageContainer.width()

        if position[1] + @largeImageContainer.height() > image.get(0).naturalHeight
          position[1] = image.get(0).naturalHeight - @largeImageContainer.height()

        @largeImageContainer.css
          "background-position": "-#{position[0]}px -#{position[1]}px"

  onMouseOut: (e) =>
    @currentImage.off 'mousemove.viewer, mouseout.viewer'
    @viewing = false
    @largeImageContainer.css 'display', 'none'

module.exports = HiggsHunterSubjectViewer
