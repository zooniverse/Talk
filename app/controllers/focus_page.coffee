Api = require 'zooniverse/lib/api'
Focus = require 'models/focus'
Page = require 'controllers/page'

class FocusPage extends Page
  className: "#{Page::className} focus"
  elements:
    '.comment-form': 'commentForm'
    '.comment-form button[type="submit"]': 'commentButton'
    '.comment-form [name="comment"]': 'commentBox'
    '.comment-form .characters-count': 'characterCounter'
    'ul.comments': 'commentList'
    '.load-more-comments': 'loadMoreComments'
  
  events:
    'submit .comment-form': 'submitComment'
    'click .new-discussion button': 'startDiscussion'
    'keyup .comment-form textarea': 'updateCounter'
    'click .load-more-comments': 'paginateComments'
  
  activate: (params) ->
    return unless params
    @focusId = params.focusId
    @commentLength = 140
    @commentPage = 1
    super
  
  url: ->
    "#{ super }/#{ @constructor::focusType }/#{ @focusId }"
  
  rootUrl: ->
    _super::url()
  
  reload: (callback) ->
    if @fetchOnLoad
      Focus.fetch @focusId, (@data) =>
        @render()
        callback @data
    else
      super
  
  updateCounter: (ev) =>
    remaining = @commentLength - @commentBox.val().length
    if remaining < 0
      @characterCounter.html """<span style="color: red;">#{ remaining }</span>"""
      @commentButton.attr 'disabled', 'disabled'
    else
      @characterCounter.html remaining
      @commentButton.removeAttr 'disabled'
  
  submitComment: (ev) ->
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      @commentForm[0].reset()
      @updateCounter()
      comment = require('views/focus/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.prepend comment
    
    ev.preventDefault()
  
  paginateComments: =>
    @commentPage += 1
    Api.get "#{ @url() }/comments?page=#{ @commentPage }", (results) =>
      @loadMoreComments.hide() if @data.discussion.comments_count < @commentPage * 10
      for comment in results
        @commentList.append require('views/focus/comment') comment: comment
  
  startDiscussion: (ev) =>
    ev.preventDefault()
    category = $(ev.target).data 'category'
    @navigate "#{ @constructor::focusType }", @focusId, category, 'discussions', 'new'

module.exports = FocusPage
