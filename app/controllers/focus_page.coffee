Api = require 'zooniverse/lib/api'
Page = require './page'

class FocusPage extends Page
  className: "#{Page::className} focus"
  elements:
    '.comment-form': 'commentForm'
    '.comment-form button[type="submit"]': 'commentButton'
    '.comment-form [name="comment"]': 'commentBox'
    'ul.comments': 'commentList'
    '.comment-form .characters .count': 'characterCounter'
  
  events:
    'submit .comment-form': 'submitComment'
    'click .new-discussion button': 'startDiscussion'
    'keyup .comment-form textarea': 'updateCounter'
  
  activate: (params) ->
    return unless params
    @focusId = params.focusId
    @commentLength = 140
    super
  
  url: ->
    "#{ super }/#{ @constructor::focusType }/#{ @focusId }"
  
  rootUrl: ->
    _super::url()
  
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
      comment = require('views/focus/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.prepend comment
    
    ev.preventDefault()
  
  startDiscussion: (ev) =>
    ev.preventDefault()
    category = $(ev.target).data 'category'
    @navigate "/#{ @constructor::focusType }", @focusId, category, 'discussions', 'new'

module.exports = FocusPage
