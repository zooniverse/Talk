DefaultSubjectViewer = require 'controllers/default_subject_viewer'
ImageInspect = require 'cs-utils-imageinspect'
$ = window.jQuery

class NotesFromNatureSubjectViewer extends DefaultSubjectViewer
  @subjectTitle: (subject) ->
    { number, species } = subject.metadata
    if number? and species? then "#{ number } #{ species }" else super

  className: "#{ DefaultSubjectViewer::className } notes-from-nature-subject-viewer"
  template: require 'views/subjects/viewer'

  constructor: ->
    super

    new ImageInspect @el.find('img.main').get(0), {
      attachPoint: 'left top img.main 1.05 0'
    }

module.exports = NotesFromNatureSubjectViewer
