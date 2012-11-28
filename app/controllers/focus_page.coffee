Api = require 'zooniverse/lib/api'
Page = require './page'

class FocusPage extends Page
  className: "#{Page::className} focus"
  elements:
    '.comment-form': 'commentForm'
    'ul.comments': 'commentList'
  
  events:
    'submit .comment-form': 'submitComment'
    'click .new-discussion button': 'startDiscussion'
  
  activate: (params) ->
    return unless params
    @focusId = params.focusId
    super
  
  url: ->
    "#{ super }/#{ @constructor::focusType }/#{ @focusId }"
  
  rootUrl: ->
    _super::url()
  
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
