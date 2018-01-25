{ project } = require './config'
Api = require 'zooniverse/lib/api'

$(document).on 'click', '.report-comment', (event) ->
  if message = prompt('Please enter a brief message describing the problem with this comment:')
    el = $(event.target)
    { commentId, discussionId } = el.data()
    body = { comment_id: commentId, discussion_id: discussionId, message: message }
    Api.post "/projects/#{ project }/talk/moderation/report_comment", body, =>
      el.replaceWith '<strong>Reported</strong>'

$(document).on 'click', '.show-for-privileged-user.remove-comment', (event) ->
  if message = prompt('Please enter a brief message describing the problem with this comment:')
    el = $(event.target)
    { commentId, discussionId } = el.data()
    body = { comment_id: commentId, discussion_id: discussionId, comment: message }

    Api.post "/projects/#{ project }/talk/moderation/delete_comment", body, =>
      el.closest('.comment,.post').remove()

$(document).on 'click', '.remove-own-comment', (event) ->
  if confirm('Are you sure you want to remove this comment?\nThere is no undo.')
    el = $(event.target)
    { commentId, discussionId } = el.data()

    Api.delete "/projects/#{ project }/talk/discussions/#{ discussionId }/comments/#{ commentId }", =>
      el.closest('.comment,.post').remove()

$(document).on 'click', '.report-user', (event) ->
  if message = prompt('Please enter a brief message describing the problem with this user:')
    el = $(event.target)
    userName = el.data 'user-name'
    Api.post "/projects/#{ project }/talk/moderation/report_user", user_name: userName, message: message, (results) =>
      el.replaceWith '<strong>Reported</strong>'

$(document).on 'click', '.user.page .ban-user', (event) ->
  if message = prompt('Please enter a brief message describing the reason for banning this user:')
    el = $(event.target)
    userName = el.data('user-name')
    Api.post "/projects/#{ project }/talk/moderation/ban_user", user_name: userName, comment: message, (results) =>
      el.closest('.user-moderation').replaceWith require('../views/moderation/user')(user: { name: userName, state: 'banned' })

$(document).on 'click', '.user.page .redeem-user', (event) ->
  if message = prompt('Please enter a brief message describing the reason for redeeming this user:')
    el = $(event.target)
    userName = el.data('user-name')
    Api.post "/projects/#{ project }/talk/moderation/redeem_user", user_name: userName, comment: message, (results) =>
      el.closest('.user-moderation').replaceWith require('../views/moderation/user')(user: { name: userName })
