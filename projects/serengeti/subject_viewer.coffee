DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = window.jQuery

modulus = (a, b) ->
  ((a % b) + b) % b

class SerengetiSubjectViewer extends DefaultSubjectViewer
  className: "#{DefaultSubjectViewer::className} serengeti-subject-viewer"
  template: template
  
  @imageIn: (location) -> location?.standard?[0]

  fps: 3

  events:
    'click button[name="play"]': 'onClickPlay'
    'click button[name="pause"]': 'onClickPause'
    'click button[name="switch-image"]': 'onClickSwitch'
    'click button[name="meme"]': 'onClickMeme'

  elements:
    '#meme-link': 'memeLink'
    '.subject-images img': 'subjectImages'
    'button[name="switch-image"]': 'imageSwitchers'

  playTimeouts: null

  constructor: ->
    super
    @playTimeouts = []

  render: ->
    super

    @activate 0

  play: =>
    @el.addClass 'playing'

    last = @subject.location.standard.length - 1
    iterator = [0...last].concat [last...0]
    iterator = iterator.concat [0...last].concat [last...0]
    iterator = iterator.concat [0...Math.floor(@subject.location.standard.length / 2) + 1]

    for index, i in iterator then do (index, i) =>
      @playTimeouts.push setTimeout (=> @activate index), i * (1000 / @fps)

    @playTimeouts.push setTimeout @pause, i * (1000 / @fps)

  pause: =>
    @el.removeClass 'playing'
    clearTimeout timeout for timeout in @playTimeouts

  activate: (index) =>
    index = +index
    @subjectImages.add(@imageSwitchers).removeClass 'active'
    @subjectImages.eq(index).addClass 'active'
    @imageSwitchers.eq(index).addClass 'active'

  onClickPlay: ->
    @play()

  onClickPause: ->
    @pause()

  onClickSwitch: ({target}) ->
    @activate $(target).val()

  onClickMeme: ->
    src = @subjectImages.filter('.active').attr 'src'
    @memeLink.attr 'href', "http://memes.snapshotserengeti.org/?u=#{ src }"

module.exports = SerengetiSubjectViewer
