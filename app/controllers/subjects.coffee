SubStack = require 'lib/sub_stack'
FocusPage = require 'controllers/focus_page'
template = require 'views/subjects/show'

class Show extends FocusPage
  template: template
  className: 'subject page'
  focusType: 'subjects'


class Subjects extends SubStack
  controllers:
    show: Show
  
  routes:
    '/subjects/:focusId': 'show'


module.exports = Subjects
