Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Show extends Page
  template: require('views/discussions/show')
  
  elements:
    'form.new-comment': 'commentForm'
    '.discussion .comments ul': 'commentList'
  
  events:
    'submit .new-comment': 'createComment'
  
  activate: (params) ->
    return unless params
    @boardId = params.boardId
    @id = params.id
    super
  
  url: =>
    "#{ super }/boards/#{ @boardId }/discussions/#{ @id }"
  
  createComment: (ev) =>
    ev.preventDefault()
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      @commentForm[0].reset()
      comment = require('views/discussions/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.append comment


class Discussions extends SubStack
  controllers:
    show: Show
  
  routes:
    '/boards/:boardId/discussions/:id': 'show'
  
  default: 'show'
  className: 'stack discussions'


module.exports = Discussions
