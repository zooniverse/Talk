Api = require 'zooniverse/lib/api'
Focus = require 'models/focus'
Page = require 'controllers/page'

class FocusPage extends Page
  className: "#{Page::className} focus"
  elements: $.extend
    '.create-comment .comment-form': 'commentForm'
    '.create-comment .comment-form .characters .count': 'characterCounter'
    '.focus-comments': 'commentList'
    '.load-more-comments': 'loadMoreComments'
    Page::elements

  events: $.extend
    'click .focus-comments .comment .comment-moderation .edit-comment': 'editComment'
    'submit .create-comment .comment-form': 'submitComment'
    'submit .edit-comment .comment-form': 'updateComment'
    'click .new-discussion button': 'startDiscussion'
    'keyup .comment-form textarea': 'updateCounter'
    'click .load-more-comments': 'paginateComments'
    Page::events

  activate: (params) ->
    return unless params
    @focusId = params.focusId.split("?")[0]
    @commentLength = 140
    @commentPage = 1
    super

  url: ->
    "#{ super }/#{ @constructor::focusType }/#{ @focusId }"

  reload: (callback) ->
    if @fetchOnLoad
      Focus.fetch @focusId, (@data) =>
        @render()
        callback @data
    else
      super

  updateCounter: (ev) =>
    commentForm = $(ev.target).closest '.comment-form'
    commentBox = commentForm.find '[name="comment"]'
    commentButton = commentForm.find 'button[type="submit"]'
    characterCounter = commentForm.find '.characters .count'

    remaining = @commentLength - commentBox.val().length
    if remaining < 0
      characterCounter.html """<span style="color: red;">#{ remaining }</span>"""
      commentButton.attr 'disabled', 'disabled'
    else
      characterCounter.html remaining
      commentButton.removeAttr 'disabled'

  submitComment: (ev) ->
    ev.preventDefault()
    submitButton = $(ev.target).find '[type="submit"]'
    submitButton.attr disabled: true

    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      submitButton.attr disabled: false
      @commentForm[0].reset()
      @characterCounter.html 0
      @data.discussion.comments.unshift response
      @commentList.prepend require('views/focus/comment')(discussionId: response.discussion_id, comment: response)

  editComment: (ev) =>
    target = $(ev.target)
    id = target.data 'comment-id'
    comment = @data.discussion.comments.filter((c) -> c._id is id)[0]
    commentEl = target.closest '.comment'
    commentEl.replaceWith require('views/focus/edit_comment_form')(discussionId: @data.discussion.zooniverse_id, comment: comment)

  updateComment: (ev) ->
    ev.preventDefault()
    target = $(ev.target).find('[type="submit"]')
    { commentId, discussionId } = target.data()
    formEl = target.closest '.edit-comment'
    body = formEl.find('[name="comment"]').val()
    Api.put "#{ Page::url() }/discussions/#{ discussionId }/comments/#{ commentId }", body: body, =>
      comment = @data.discussion.comments.filter((c) -> c._id is commentId)[0]
      comment.body = body
      formEl.replaceWith require('views/focus/comment')(discussionId: discussionId, comment: comment)

  paginateComments: =>
    @commentPage += 1
    Api.get "#{ @url() }/comments?page=#{ @commentPage }", (results) =>
      @loadMoreComments.hide() if @data.discussion.comments_count < @commentPage * 10
      for comment in results
        @commentList.append require('views/focus/comment') comment: comment

  startDiscussion: (ev) =>
    ev.preventDefault()
    category = $(ev.target).data 'category'
    @navigate '', @constructor::focusType, @focusId, category, 'discussions', 'new'

module.exports = FocusPage
