require 'lib/setup'

{Stack} = require 'spine/lib/manager'
$ = require 'jqueryify'

AppHeader = require 'controllers/app_header'
ObjectPage = require 'controllers/object_page'

app = {}
app.el = $('#app')

app.header = new AppHeader
app.header.el.prependTo app.el

app.mainStack = new Stack
  el: '#main > .pages'

  controllers:
    subjectPage: ObjectPage

  routes:
    '/subjects/:subjectId': 'subjectPage'

  default: 'subjectPage'

module.exports = app
