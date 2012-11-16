require 'lib/setup'

{Stack} = require 'spine/lib/manager'
$ = require 'jqueryify'

ObjectPage = require 'controllers/object_page'

app = {}

app.mainStack = new Stack
  el: '#main > .pages'

  controllers:
    subjectPage: ObjectPage

  routes:
    '/subjects/:subjectId': 'subjectPage'

  default: 'subjectPage'

module.exports = app
