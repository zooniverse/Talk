Api = require 'zooniverse/lib/api'
Page = require './page'

class FocusPage extends Page
  className: "object #{Page::className}"
  
  elements:
    '.comment-form': 'commentForm'
    '.comments ul': 'commentList'
  
  events:
    'submit .comment-form': 'submitComment'
    'click .new-board-discussion button': 'startDiscussion'
  
  activate: (params) ->
    return unless params
    @focusId = params.focusId
    super
  
  url: ->
    "#{ super }/#{ @focus_type }/#{ @focusId }"
  
  submitComment: (ev) ->
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      @commentForm[0].reset()
      comment = require('views/focus/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.prepend comment
    
    ev.preventDefault()
  
  startDiscussion: (ev) =>
    @navigate "/#{ @focus_type }/#{ @focusId }/discussions/new"
    ev.preventDefault()

module.exports = FocusPage
