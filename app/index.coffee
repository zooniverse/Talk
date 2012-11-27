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
Trending = require 'controllers/trending'
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
    trending: Trending
    subjects: Subjects
    boards: Boards
    discussions: Discussions
    collections: Collections
  
  routes:
    '/': 'trending'
    '/trending': 'trending'
    '/subjects': 'subjects'
    '/collections': 'collections'
    '/boards': 'boards'
    '/:focusType/:focusId/discussions': 'discussions'
  
  default: 'trending'

Spine.Route.setup()
app.stack.el.appendTo app.el

activateMatchingHashLinks = ->
  $('a.active').removeClass 'active'
  setTimeout ->
    segments = location.hash.split '/'
    hashes = (segments[..i].join '/' for _, i in segments)
    $("a[href='#{hash}']").addClass 'active' for hash in hashes

$(window).on 'hashchange', activateMatchingHashLinks
setTimeout activateMatchingHashLinks

module.exports = app
