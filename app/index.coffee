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
Subjects = require 'controllers/subjects'
Collections = require 'controllers/collections'
Boards = require 'controllers/boards'
Discussions = require 'controllers/discussions'

app = {}
app.el = $('#app')

app.header = new AppHeader
app.header.el.prependTo app.el

app.stack = new Stack
  controllers:
    subjects: Subjects
    boards: Boards
    discussions: Discussions
    collections: Collections
  
  routes:
    '/subjects': 'subjects'
    '/collections': 'collections'
    '/boards': 'boards'
    '/:focusType/:focusId/discussions': 'discussions'
  
  default: 'boards'

Spine.Route.setup()
app.stack.el.appendTo app.el

module.exports = app
