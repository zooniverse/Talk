Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Show extends Page
  template: require('views/boards/show')
  
  elements:
    'form.new-discussion': 'discussionForm'
  
  events:
    'submit .new-discussion': 'createDiscussion'
  
  activate: (params) ->
    return unless params
    @id = params.id
    super
  
  url: =>
    "#{ super }/boards/#{ @id }"
  
  createDiscussion: (ev) =>
    ev.preventDefault()
    
    Api.post "#{ @url() }/discussions", @discussionForm.serialize(), (response) =>
      @navigate '/boards', @id, 'discussions', response.zooniverse_id


class Index extends Page
  template: require('views/boards/index')
  
  events:
    'click button[name="new-board"]': 'newBoard'
  
  url: ->
    "#{ super }/boards"
  
  newBoard: ({ target }) ->
    category = $(target).val()
    @navigate '/boards', category, 'new'


class New extends Page
  template: require('views/boards/new')
  fetchOnLoad: false
  
  elements:
    'form.new-board': 'form'
  
  events:
    'submit form.new-board': 'createBoard'
  
  url: ->
    "#{ super }/boards"
  
  activate: (params) ->
    return unless params
    @category = params.category
    super
  
  createBoard: (ev) ->
    ev.preventDefault()
    
    Api.post @url(), @form.serialize(), (result) =>
      @navigate '/boards', result.zooniverse_id


class Boards extends SubStack
  controllers:
    show: Show
    index: Index
    new: New
  
  routes:
    '/boards': 'index'
    '/boards/:id': 'show'
    '/boards/:category/new': 'new'
  
  default: 'index'
  className: 'stack boards'

module.exports = Boards
