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
    { @focusType, @focusId } = params
    @id = params.id
    super
  
  url: =>
    "#{ super }/#{ @focusType }/#{ @focusId }/discussions/#{ @id }"
  
  createComment: (ev) =>
    ev.preventDefault()
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      @commentForm[0].reset()
      comment = require('views/discussions/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.append comment


class New extends Page
  template: require('views/discussions/new')
  fetchOnLoad: false
  
  elements:
    'form.new-discussion': 'form'
  
  events:
    'submit form.new-discussion': 'createDiscussion'
  
  url: ->
    "#{ super }/#{ @focusType }/#{ @focusId }/discussions"
  
  activate: (params) ->
    return unless params
    { @category, @focusType, @focusId } = params
    super
  
  createDiscussion: (ev) =>
    ev.preventDefault()
    Api.post @url(), @form.serialize(), (result) =>
      @navigate "/#{ @focusType }", @focusId, 'discussions', result.zooniverse_id


class Discussions extends SubStack
  controllers:
    show: Show
    new: New
  
  routes:
    '/:focusType/:focusId/discussions/new': 'new'
    '/:focusType/:focusId/:category/discussions/new': 'new'
    '/:focusType/:focusId/discussions/:id': 'show'
  
  default: 'show'
  className: 'stack discussions'


module.exports = Discussions
