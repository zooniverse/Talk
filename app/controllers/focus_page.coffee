Api = require 'zooniverse/lib/api'
Page = require './page'

class FocusPage extends Page
  elements:
    '.comment-form': 'commentForm'
    '.comments ul': 'commentList'
  
  events:
    'submit .comment-form': 'submitComment'
    'click .new-discussion button': 'startDiscussion'
  
  activate: (params) ->
    return unless params
    @focusId = params.focusId
    super
  
  url: ->
    "#{ super }/#{ @constructor::focusType }/#{ @focusId }"
  
  submitComment: (ev) ->
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      @commentForm[0].reset()
      comment = require('views/focus/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.prepend comment
    
    ev.preventDefault()
  
  startDiscussion: (ev) =>
    @navigate "/#{ @constructor::focusType }", @focusId, 'discussions', 'new'
    ev.preventDefault()

module.exports = FocusPage
