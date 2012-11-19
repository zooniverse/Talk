require 'lib/setup'

{Stack} = require 'spine/lib/manager'
$ = require 'jqueryify'

Config = require 'lib/config'
Api = require 'zooniverse/lib/api'
Api.init host: Config.apiHost
User = require 'zooniverse/lib/models/user'
User.project = Config.project
User.fetch()

AppHeader = require 'controllers/app_header'
SubjectPage = require 'controllers/subject_page'

app = {}
app.el = $('#app')

app.header = new AppHeader
app.header.el.prependTo app.el

app.stack = new Stack
  controllers:
    subjectPage: SubjectPage

  routes:
    '/subjects/:focusId': 'subjectPage'

  default: 'subjectPage'

Spine.Route.setup()
app.stack.el.appendTo app.el

module.exports = app
