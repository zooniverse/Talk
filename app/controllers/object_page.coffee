Api = require 'zooniverse/lib/api'
Page = require './page'
template = require 'views/object_page'

class ObjectPage extends Page
  className: "object #{Page::className}"
  template: template
  
  elements:
    '.comment-form': 'commentForm'
    '.comments ul': 'commentList'
  
  events:
    'submit .comment-form': 'submitComment'
  
  activate: (params) ->
    return unless params
    @subjectId = params.subjectId
    super
  
  url: ->
    "#{ super }/subjects/#{ @subjectId }"
  
  submitComment: (ev) ->
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      @commentForm[0].reset()
      comment = require('views/focus/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.prepend comment
      console.log comment
    
    ev.preventDefault()

module.exports = ObjectPage
