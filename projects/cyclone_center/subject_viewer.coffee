DefaultSubjectViewer = require 'controllers/default_subject_viewer'
template = require 'views/subjects/viewer'
$ = require 'jqueryify'

class CycloneCenterSubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } cyclone-center-subject-viewer"
  template: template
  
  @subjectTitle: (subject) ->
    """
      Image #{ subject.zooniverse_id } from
      <a class="subject-group" href="#/groups/#{ subject.group.zooniverse_id }">#{ subject.group.name }</a>
    """
  
  @imageIn: (location) ->
    params = window.location.search.slice 1, window.location.search.length
    paramPairs = params.split('&').map((pair) -> pair.split '=')

    selectedSatellite = null

    for pair in paramPairs
      if pair[0] == 'satellite'
        selectedSatellite = pair[1]
        return location[selectedSatellite] if selectedSatellite of location

    for key, url of location
      return url unless key.match(/yesterday$/)

module.exports = CycloneCenterSubjectViewer
