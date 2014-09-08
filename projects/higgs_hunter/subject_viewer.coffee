DefaultSubjectViewer = require 'controllers/default_subject_viewer'
$ = require 'jqueryify'

class HiggsHunterSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } higgs-hunter-subject-viewer"
  template: require 'views/subjects/viewer'

  viewing: false

  elements:
    'img.main': 'subjectImage'
    '.large-mouseover': 'largeImageContainer'

  events:
    'mouseover img.main': 'onMouseOver'

  constructor: ->
    super

    @largeImageContainer.css
      "background-image": "url(\"#{@subject.location.standard}\")"

  onMouseOver: (e) =>
    @height = @el.get(0).clientHeight
    @width = @el.get(0).clientWidth
    @widthRatio = @subjectImage.get(0).naturalWidth / @width
    @heightRatio = @subjectImage.get(0).naturalHeight / @height

    @viewing = true
    @largeImageContainer.css
      'display': 'block'
      'max-width': @subjectImage.get(0).naturalWidth

    @subjectImage.on 'mouseout.viewer', @onMouseOut

    box = [@width * 0.33, @height * 0.33]

    @subjectImage.on 'mousemove.viewer', (mm_e) =>
      if @viewing
        offsetX = mm_e.pageX - @subjectImage.parent().offset().left
        offsetY = mm_e.pageY - @subjectImage.parent().offset().top

        position = [(offsetX - (box[0] / 2)) * @widthRatio, ((offsetY - (box[1] / 2)) * @heightRatio)]
        position = (for axis in position then parseInt(Math.max(axis, 0)))

        if position[0] + @largeImageContainer.width() > @subjectImage.get(0).naturalWidth
          position[0] = @subjectImage.get(0).naturalWidth - @largeImageContainer.width()

        if position[1] + @largeImageContainer.height() > @subjectImage.get(0).naturalHeight
          position[1] = @subjectImage.get(0).naturalHeight - @largeImageContainer.height()

        @largeImageContainer.css
          "background-position": "-#{position[0]}px -#{position[1]}px"

  onMouseOut: (e) =>
    @subjectImage.off 'mousemove.viewer, mouseout.viewer'
    @viewing = false
    @largeImageContainer.css 'display', 'none'

module.exports = HiggsHunterSubjectViewer
