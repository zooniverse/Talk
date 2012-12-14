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
Messages = require 'controllers/messages'
Users = require 'controllers/users'
Roles = require 'models/roles'
User = require 'zooniverse/lib/models/user'
User.project = project
googleAnalytics = require 'zooniverse/lib/google_analytics'

app = {}

googleAnalytics.init
  account: 'UA-1224199-36'
  domain: 'snapshotserengeti.org'


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

User.bind 'sign-in', ->
  if User.current
    roles = Roles.roles[User.current.name] or []
    User.current.roles = roles
    User.current[role] = true for role in roles
    $('html').addClass('privileged-user') if User.current.moderator or User.current.admin

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
        messages: Messages
      
      routes:
        '/': 'trending'
        '/trending': 'trending'
        '/following': 'following'
        '/subjects': 'subjects'
        '/collections': 'collections'
        '/boards': 'boards'
        '/profile': 'users'
        '/users': 'users'
        '/messages': 'messages'
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

$(window).on 'click', '.report-comment', (event) ->
  if message = prompt('Please enter a brief message describing the problem with this comment:')
    el = $(event.target)
    { commentId, discussionId } = el.data()
    body = { comment_id: commentId, discussion_id: discussionId, message: message }
    Api.post "/projects/#{ project }/talk/moderation/report_comment", body, =>
      el.replaceWith '<strong>Reported</strong>'

$(window).on 'click', '.show-for-privileged-user.remove-comment', (event) ->
  if message = prompt('Please enter a brief message describing the problem with this comment:')
    el = $(event.target)
    { commentId, discussionId } = el.data()
    body = { comment_id: commentId, discussion_id: discussionId, comment: message }
    
    Api.post "/projects/#{ project }/talk/moderation/delete_comment", body, =>
      el.closest('.comment,.post').remove()

$(window).on 'click', '.remove-own-comment', (event) ->
  if confirm('Are you sure you want to remove this comment?\nThere is no undo.')
    el = $(event.target)
    { commentId, discussionId } = el.data()
    
    Api.delete "/projects/#{ project }/talk/discussions/#{ discussionId }/comments/#{ commentId }", =>
      el.closest('.comment,.post').remove()



window.defaultAvatar = (el) ->
  $(el).replaceWith require('views/users/default_avatar')()


module.exports = app
