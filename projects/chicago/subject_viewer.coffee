Api = require 'zooniverse/lib/api'
DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require '../../views/subjects/viewer'
$ = window.jQuery

uniqueId = 0

class ChicagoSubjectViewer extends DefaultSubjectViewer
  @imageIn: (location, focus) ->
    return location.thumb unless focus?._id
    request = Api.get "projects/chicago/subjects/#{ focus._id }"
    request.deferred

  @afterSubjectFetch: (_refId, rawSubject) ->
    src = if 'human' in Object.keys(rawSubject.metadata.counters)
      '//placehold.it/300x215&text=Human'
    else
      rawSubject.location.thumb

    img = document.querySelector('[data-refresh-key="' + _refId + '"]')
    img.src = src

  @uniqueId: ->
    uniqueId += 1
    uniqueId

  className: "#{ DefaultSubjectViewer::className } chicago-subject-viewer"
  template: template

module.exports = ChicagoSubjectViewer
