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
    'form.new-collection .keywords label': 'keywordList'
  
  events:
    'submit form.new-collection': 'createCollection'
    'change form.new-collection select[name="type"]': 'changeType'
    'click form.new-collection .keywords .keyword .remove': 'removeKeyword'
    'click form.new-collection .keywords .add': 'addKeyword'
  
  url: ->
    "#{ super }/collections"
  
  activate: (params) ->
    return unless params
    @type = 'SubjectSet'
    @keywords = []
    
    if params.subjectId
      @subjectId = params.subjectId
    else if params.keywords
      @type = 'KeywordSet'
      @keywords = params.keywords.split '&'
    
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
    $('form.new-collection .keywords .keyword').each (i, el) =>
      tag = $('.tag', el).val()
      operator = $('.operator', el).val()
      name = "name='keywords[#{ tag }]'"
      value = "value='#{ operator }'"
      
      $("[#{ name }]", el).remove()
      $(el).append """<input type="hidden" #{ name } #{ value }>"""
  
  removeKeyword: (ev) ->
    ev.preventDefault()
    $(ev.target).closest('.keyword').remove()
  
  addKeyword: (ev) =>
    ev.preventDefault()
    @keywordList.append require('views/collections/keyword_field')({ })


class Collections extends SubStack
  controllers:
    show: Show
    new: New
  
  routes:
    '/collections/new': 'new'
    '/collections/new/keywords/*keywords': 'new'
    '/collections/new/:subjectId': 'new'
    '/collections/:focusId': 'show'


module.exports = Collections
