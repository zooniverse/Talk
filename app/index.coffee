require 'lib/setup'

{Stack} = require 'spine/lib/manager'
$ = require 'jqueryify'

AppHeader = require 'controllers/app_header'
ObjectPage = require 'controllers/object_page'

app = {}
app.el = $('#app')

app.header = new AppHeader
app.header.el.prependTo app.el

app.stack = new Stack
  controllers:
    subjectPage: ObjectPage

  routes:
    '/subjects/:subjectId': 'subjectPage'

  default: 'subjectPage'

app.stack.el.appendTo app.el

module.exports = app
