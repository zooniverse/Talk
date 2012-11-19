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

BoardIndex = require 'controllers/board_index'
BoardShow = require 'controllers/board_show'
BoardCategory = require 'controllers/board_category'

app = {}
app.el = $('#app')

app.header = new AppHeader
app.header.el.prependTo app.el

app.stack = new Stack
  controllers:
    subjectPage: SubjectPage
    boardIndex: BoardIndex
    boardShow: BoardShow
    boardCategory: BoardCategory

  routes:
    '/subjects/:focusId': 'subjectPage'
    '/boards': 'boardIndex'
    '/boards/help': 'boardCategory'
    '/boards/science': 'boardCategory'
    '/boards/chat': 'boardCategory'
    '/boards/:id': 'boardShow'

  default: 'subjectPage'

Spine.Route.setup history: true
app.stack.el.appendTo app.el

module.exports = app
