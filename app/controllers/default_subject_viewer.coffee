{Controller} = require 'spine'

class DefaultSubjectViewer extends Controller
  subject: null

  className: 'subject-viewer'

  template: (subject) -> """
    <img src="#{subject.location.standard[0]}" class="main" />
  """

  constructor: ->
    super
    @render()

  render: ->
    @el.html @template @subject

  destroy: ->
    @el.off()

module.exports = DefaultSubjectViewer
