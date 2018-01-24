DefaultSubjectViewer = require 'controllers/default_subject_viewer'
ImageInspect = require 'cs-utils-imageinspect'
$ = window.jQuery

class WarDiarySubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } war-diary-subject-viewer"
  template: require 'views/subjects/viewer'

  constructor: ->
    super
    new ImageInspect @el.find('img.main').get(0), {
      attachPoint: 'left top img.main 1.05 0'
      width: 600
    }

module.exports = WarDiarySubjectViewer
