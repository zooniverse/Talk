FocusPage = require 'controllers/focus_page'
template = require 'views/subject_page'

class SubjectPage extends FocusPage
  template: template
  focus_type: 'subjects'

module.exports = SubjectPage
