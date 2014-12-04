require 'lib/setup'

spinner = new Spinner({width: 3}).spin document.querySelector('#app')

{Stack} = require 'spine/lib/manager'
$ = require 'jqueryify'

{ project, projectName, apiHost, analytics } = require 'lib/config'
Api = require 'zooniverse/lib/api'
Api.init host: apiHost

AppHeader = require 'controllers/app_header'
Following = require 'controllers/following'
Recents = require 'controllers/recents'
Subjects = require 'controllers/subjects'
Groups = require 'controllers/groups'
Collections = require 'controllers/collections'
Boards = require 'controllers/boards'
Discussions = require 'controllers/discussions'
Moderation = require 'controllers/moderation'
Messages = require 'controllers/messages'
Search = require 'controllers/search'
Users = require 'controllers/users'
Roles = require 'models/roles'
User = require 'zooniverse/lib/models/user'
User.project = project
googleAnalytics = require 'zooniverse/lib/google_analytics'
require 'lib/moderation_links'
require 'lib/follow_links'
require 'lib/message_counter'

app = {}
googleAnalytics.init analytics

document.title = "#{projectName} Talk"

activateMatchingHashLinks = ->
  $('a.active').removeClass 'active'
  setTimeout ->
    segments = location.hash.split '/'
    hashes = (segments[..i].join '/' for _, i in segments)
    $("a[href='#{hash}']").addClass 'active' for hash in hashes

User.bind 'sign-in', ->
  if User.current?.talk?.state is 'banned'
    $('body').html require('views/users/banned')()

User.bind 'sign-in', ->
  signedIn = User.current?
  $('html').toggleClass 'signed-in', signedIn
  $('html').toggleClass 'not-signed-in', not signedIn

User.bind 'sign-in', ->
  if User.current
    roles = Roles.roles[User.current.name] or []
    User.current.roles = roles
    User.current[role] = true for role in roles
    if User.current.moderator or User.current.admin or User.current.team
      $('html').addClass('privileged-user')
      User.current.isPrivileged = true

Roles.fetch ->
  User.fetch().onSuccess ->
    spinner.stop()

    app.el = $('#app')
    
    app.header = new AppHeader
    app.header.el.prependTo app.el
    
    app.stack = new Stack
      controllers:
        recents: Recents
        following: Following
        subjects: Subjects
        groups: Groups
        boards: Boards
        discussions: Discussions
        collections: Collections
        users: Users
        messages: Messages
        moderation: Moderation
        search: Search
      
      routes:
        '/': 'recents'
        '/recent': 'recents'
        '/following': 'following'
        '/subjects': 'subjects'
        '/groups': 'groups'
        '/collections': 'collections'
        '/boards': 'boards'
        '/profile': 'users'
        '/users': 'users'
        '/messages': 'messages'
        '/moderation': 'moderation'
        '/search': 'search'
        '/:focusType/:focusId/discussions': 'discussions'
      
      default: 'recents'
    
    Spine.Route.setup()
    app.stack.el.appendTo app.el
    
    setTimeout activateMatchingHashLinks

$(window).on 'hashchange', activateMatchingHashLinks

window.defaultAvatar = (el) ->
  $(el).removeAttr 'onerror'
  $(el).replaceWith require('views/users/default_avatar')()

module.exports = app
