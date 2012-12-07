require 'lib/setup'

{Stack} = require 'spine/lib/manager'
$ = require 'jqueryify'

{ project, apiHost } = require 'lib/config'
Api = require 'zooniverse/lib/api'
Api.init host: apiHost

AppHeader = require 'controllers/app_header'
Trending = require 'controllers/trending'
Following = require 'controllers/following'
Subjects = require 'controllers/subjects'
Collections = require 'controllers/collections'
Boards = require 'controllers/boards'
Discussions = require 'controllers/discussions'
Users = require 'controllers/users'
Roles = require 'models/roles'
User = require 'zooniverse/lib/models/user'
User.project = project

app = {}

activateMatchingHashLinks = ->
  $('a.active').removeClass 'active'
  setTimeout ->
    segments = location.hash.split '/'
    hashes = (segments[..i].join '/' for _, i in segments)
    $("a[href='#{hash}']").addClass 'active' for hash in hashes

User.bind 'sign-in', ->
  signedIn = User.current?
  $('html').toggleClass 'signed-in', signedIn
  $('html').toggleClass 'not-signed-in', not signedIn

Roles.fetch ->
  User.fetch().onSuccess ->
    app.el = $('#app')
    
    app.header = new AppHeader
    app.header.el.prependTo app.el
    
    app.stack = new Stack
      controllers:
        trending: Trending
        following: Following
        subjects: Subjects
        boards: Boards
        discussions: Discussions
        collections: Collections
        users: Users
      
      routes:
        '/': 'trending'
        '/trending': 'trending'
        '/following': 'following'
        '/subjects': 'subjects'
        '/collections': 'collections'
        '/boards': 'boards'
        '/profile': 'users'
        '/users': 'users'
        '/:focusType/:focusId/discussions': 'discussions'
      
      default: 'trending'
    
    Spine.Route.setup()
    app.stack.el.appendTo app.el

    setTimeout activateMatchingHashLinks

$(window).on 'hashchange', activateMatchingHashLinks

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

window.defaultAvatar = (el) ->
  $(el).replaceWith require('views/users/default_avatar')()


module.exports = app
