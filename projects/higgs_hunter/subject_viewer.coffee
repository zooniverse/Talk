DefaultSubjectViewer = require 'controllers/default_subject_viewer'
ImageInspect = require 'cs-utils-imageinspect'
$ = require 'jqueryify'

names = ['first', 'second', 'third']

class HiggsHunterSubjectViewer extends DefaultSubjectViewer
  @imageIn: (location) -> location?.standard?[1]

  className: "#{ DefaultSubjectViewer::className } higgs-hunter-subject-viewer"
  template: require 'views/subjects/viewer'

  viewing: false
  images: []

  elements:
    '.subject-images img': 'subjectImages'

  events:
    'click button.action': 'onClickAction'

  constructor: ->
    super

    @subjectImages.eq(1).show()

    @subjectImages.each (i) ->
      new ImageInspect @, {
        attachPoint: 'top left .subject-images 1.05 0'
        width: 500
        height: 450
      }

  onClickAction: (e) =>
    view = @el.get 0
    target = $(e.currentTarget).data('target')

    @subjectImages.hide()
    @subjectImages.filter("[data-target=\"#{ +target }\"]").show()

module.exports = HiggsHunterSubjectViewer
