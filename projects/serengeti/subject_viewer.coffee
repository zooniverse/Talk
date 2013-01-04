DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

modulus = (a, b) ->
  ((a % b) + b) % b

# memeDialogTemplate = """
#   <div class="serengeti-meme-dialog">
#     <button name="close">

#     <form name="memeify">
#       <input type="text" name="topText" placeholder="" />
#       <input type="text" name="bottomText" placeholder="" />
#       <button type="submit"></button>
#     </form>

#     <div class="response">
#       <img src="" class="memeified" />
#       <input type="text" name="memeified-src" readonly="readonly" value="" />
#     </div>
#   </div>
# """

class SerengetiSubjectViewer extends DefaultSubjectViewer
  className: "#{DefaultSubjectViewer::className} serengeti-subject-viewer"
  template: template

  fps: 3

  events:
    'click button[name="play"]': 'onClickPlay'
    'click button[name="pause"]': 'onClickPause'
    'click button[name="switch-image"]': 'onClickSwitch'
    # 'click button[name="meme"]': 'onClickMeme'

  elements:
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

  # onClickMeme: ->
  #   src = @subjectImages.filter('.active').attr 'src'
  #   top = prompt('Top line') || ' '
  #   bottom = prompt('Bottom line') || ' '

  #   $.get "http://serengeti-meme.herokuapp.com/newMeme?image=#{src}&topText=#{top}&bottomText=#{bottom}", (memeSrc) =>
  #     open memeSrc

module.exports = SerengetiSubjectViewer
