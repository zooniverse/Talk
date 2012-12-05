Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
FocusPage = require 'controllers/focus_page'
template = require 'views/subjects/show'
$ = require 'jqueryify'

class Show extends FocusPage
  template: template
  className: "#{FocusPage::className} subject page"
  focusType: 'subjects'


class Subjects extends SubStack
  controllers:
    show: Show
  
  routes:
    '/subjects/:focusId': 'show'


module.exports = Subjects
