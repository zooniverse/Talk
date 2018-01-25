DefaultSubjectViewer = require 'controllers/default_subject_viewer'
$ = window.jQuery

class MilkyWaySubjectViewer extends DefaultSubjectViewer
  className: "#{ DefaultSubjectViewer::className } milky-way-subject-viewer"
  template: require '../../views/subjects/viewer'

  constructor: ->
    super

    button = document.createElement 'button'
    button.className = 'explore-this'
    button.innerHTML = 'Explore'
    $(button).appendTo '.focus > .add-to-collection'

    button.addEventListener 'click', (e) =>
      window.location = "http://explore.milkywayproject.org/subjects/#{ @subject.zooniverse_id }"

module.exports = MilkyWaySubjectViewer
