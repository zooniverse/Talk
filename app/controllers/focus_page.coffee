Api = require 'zooniverse/lib/api'
Focus = require 'models/focus'
Page = require 'controllers/page'

class FocusPage extends Page
  className: "#{Page::className} focus"
  elements: $.extend
    '.comment-form': 'commentForm'
    '.comment-form button[type="submit"]': 'commentButton'
    '.comment-form [name="comment"]': 'commentBox'
    '.comment-form .characters .count': 'characterCounter'
    '.focus-comments': 'commentList'
    '.load-more-comments': 'loadMoreComments'
    Page::elements
  
  events: $.extend
    'submit .comment-form': 'submitComment'
    'click .new-discussion button': 'startDiscussion'
    'keyup .comment-form textarea': 'updateCounter'
    'click .load-more-comments': 'paginateComments'
    Page::events
  
  activate: (params) ->
    return unless params
    @focusId = params.focusId
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
    remaining = @commentLength - @commentBox.val().length
    if remaining < 0
      @characterCounter.html """<span style="color: red;">#{ remaining }</span>"""
      @commentButton.attr 'disabled', 'disabled'
    else
      @characterCounter.html remaining
      @commentButton.removeAttr 'disabled'
  
  submitComment: (ev) ->
    submitButton = $(ev.target).find '[type="submit"]'
    submitButton.attr disabled: true

    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      submitButton.attr disabled: false
      @commentForm[0].reset()
      @updateCounter()
      @commentList.prepend require('views/focus/comment')(comment: response)
    
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
    @navigate '', @constructor::focusType, @focusId, category, 'discussions', 'new'

module.exports = FocusPage
