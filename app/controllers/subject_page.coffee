FocusPage = require 'controllers/focus_page'
template = require 'views/subject_page'

class SubjectPage extends FocusPage
  template: template
  className: 'subject page'
  focusType: 'subjects'

module.exports = SubjectPage
