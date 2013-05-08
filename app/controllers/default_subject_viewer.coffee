{Controller} = require 'spine'

class DefaultSubjectViewer extends Controller
  @imageIn: (location) -> location?.standard
  @subjectTitle: (subject) -> "Image #{ subject.zooniverse_id }"
  
  subject: null

  className: 'subject-viewer'

  template: -> """
    <img src="#{@subject.location.standard[0]}" class="main" />
  """

  constructor: ->
    super
    @render()

  render: ->
    @html @template @

  destroy: ->
    @el.off()

module.exports = DefaultSubjectViewer
