Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'
FocusPage = require 'controllers/focus_page'
template = require 'views/collections/show'

class Show extends FocusPage
  template: template
  className: 'collection page'
  focusType: 'collections'


class New extends Page
  template: require('views/collections/new')
  fetchOnLoad: false
  
  elements:
    'form.new-collection': 'form'
    'form.new-collection select[name="type"]': 'typeSelector'
    'form.new-collection .keywords .keyword': 'keywords'
  
  events:
    'submit form.new-collection': 'createCollection'
    'change form.new-collection select[name="type"]': 'changeType'
    'click form.new-collection .keywords .keyword .remove': 'removeKeyword'
  
  url: ->
    "#{ super }/collections"
  
  activate: (params) ->
    return unless params
    @type = 'SubjectSet'
    super
  
  changeType: (ev) ->
    @type = @typeSelector.val()
    @render()
  
  createCollection: (ev) ->
    ev.preventDefault()
    @serializeTags() if @type is 'KeywordSet'
    Api.post @url(), @form.serialize(), (result) =>
      @navigate '/collections', result.zooniverse_id
  
  serializeTags: =>
    tags = { }
    @keywords.each (i, el) =>
      tag = $('.tag', el).val()
      operator = $('.operator', el).val()
      name = "name='keywords[#{ tag }]'"
      value = "value='#{ operator }'"
      
      $("[#{ name }]", el).remove()
      $(el).append """<input type="hidden" #{ name } #{ value }>"""
  
  removeKeyword: (ev) ->
    $(ev.target).closest('.keyword').remove()


class Collections extends SubStack
  controllers:
    show: Show
    new: New
  
  routes:
    '/collections/new': 'new'
    '/collections/:focusId': 'show'


module.exports = Collections
