DefaultSubjectViewer = require 'controllers/default_subject_viewer'
ImageInspect = require 'cs-utils-imageinspect'
$ = require 'jqueryify'

loadImage = (src, cb) ->
  image = new Image
  image.onload = ->
    cb image if cb?
  image.src = src

class SunspotSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } sunspot-subject-viewer"
  template: require 'views/subjects/viewer'

  viewing: false

  elements:
    'img.context': 'subjectContextImage'
    '.subject-images': 'subjectImages'

  events:
    'click button.action': 'onClickAction'

  constructor: ->
    super

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

      new ImageInspect @contextImage, {
        attachPoint: 'left top img.main 1.05 0'
        width: 450
        height: 450 
      }

      @contextImage = $(@contextImage)
      @subjectImages.append @contextImage

  onClickAction: (e) =>
    view = @el.get 0
    { target } = e.currentTarget.dataset

    hideThese = Array::slice.call view.querySelectorAll('.targets'), 0
    element.style.display = 'none' for element in hideThese

    showThese = Array::slice.call view.querySelectorAll(".#{ target }"), 0
    element.style.display = 'block' for element in showThese

module.exports = SunspotSubjectViewer
