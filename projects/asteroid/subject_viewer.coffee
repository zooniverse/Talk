DefaultSubjectViewer = require 'controllers/default_subject_viewer'
$ = window.jQuery

class AsteroidSubjectViewer extends DefaultSubjectViewer
  @imageIn: (location) -> location?.standard?[0]
  className: "#{ DefaultSubjectViewer::className } asteroid-subject-viewer"
  template: require '../../views/subjects/viewer'

  activeFrame: 0
  playing: false
  delay: 550

  elements:
    '.images-container img': 'subjectImages'
    '.frames-container .frame': 'subjectFrames'
    'button[name="playPause"]': 'playPauseButton'

  events:
    'click .frame': 'onClickFrame'
    'click button[name="playPause"]': 'onClickPlayPause'

  constructor: ->
    super
    @subjectFrames.first().click()

  onClickFrame: ({ currentTarget }) =>
    @activeFrame = parseInt currentTarget.dataset.frame

    $(currentTarget).siblings().removeClass 'active'
    $(currentTarget).toggleClass 'active', true

    @subjectImages.removeClass 'active'
    @subjectImages.eq(@activeFrame).addClass 'active'

  onClickPlayPause: =>
    if @playing
      clearInterval @playing
      @playing = false
      @playPauseButton.removeClass 'active'
      return

    @next()
    @playPauseButton.addClass 'active'
    @playing = setInterval =>
      if @playing then @next()
    , @delay

  next: =>
    @activeFrame += 1
    if @activeFrame >= @subjectFrames.length
      @activeFrame = 0
    @subjectFrames.eq(@activeFrame).click()

module.exports = AsteroidSubjectViewer
