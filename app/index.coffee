require 'lib/setup'

{Stack} = require 'spine/lib/manager'
$ = require 'jqueryify'

{ project, apiHost } = require 'lib/config'
Api = require 'zooniverse/lib/api'
Api.init host: apiHost
User = require 'zooniverse/lib/models/user'
User.project = project
User.fetch()

AppHeader = require 'controllers/app_header'
Trending = require 'controllers/trending'
Subjects = require 'controllers/subjects'
Collections = require 'controllers/collections'
Boards = require 'controllers/boards'
Discussions = require 'controllers/discussions'
Users = require 'controllers/users'

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
    users: Users
  
  routes:
    '/': 'trending'
    '/trending': 'trending'
    '/subjects': 'subjects'
    '/collections': 'collections'
    '/boards': 'boards'
    '/users': 'users'
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

$(window).on 'click', '.follow-link button', (event) ->
  event.preventDefault()
  link = $(event.target)
  action = link.attr 'name'
  id = link.data 'id'
  type = link.data 'type'
  link.attr 'disabled', 'disabled'
  
  url = "/projects/#{ project }/talk/following/#{ action }"
  hash =
    type: type
    id: id
  
  Api.post url, hash, =>
    followed = action is 'follow'
    link.closest('.follow').replaceWith require('views/follow_button')(id: id, type: type, followed: followed)


module.exports = app
