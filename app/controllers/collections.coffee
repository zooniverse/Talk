Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'
FocusPage = require 'controllers/focus_page'
template = require 'views/collections/show'

class Show extends FocusPage
  template: template
  className: "#{FocusPage::className} collection page"
  focusType: 'collections'


class New extends Page
  action: 'new'
  className: "#{Page::className} new collection"
  template: require('views/collections/new')
  fetchOnLoad: false
  
  elements:
    'form.new-collection': 'form'
    'form.new-collection select[name="type"]': 'typeSelector'
    'form.new-collection .keywords': 'keywordList'
  
  events:
    'submit form.new-collection': 'onSubmit'
    'change form.new-collection select[name="type"]': 'changeType'
    'click button[name="remove-keyword"]': 'removeKeyword'
    'click button[name="add-keyword"]': 'addKeyword'
  
  url: ->
    "#{ super }/collections"
  
  activate: (params) ->
    return unless params

    @id = params.id
    @subjectId = params.subjectId
    @keywords = params.keywords?.split '&'

    if params.subjectId
      @type = 'SubjectSet'
    else if params.keywords
      @type = 'KeywordSet'

    super
  
  changeType: (ev) ->
    @type = @typeSelector.val()
    @render()
  
  onSubmit: (ev) ->
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


class Edit extends New
  className: "#{Page::className} edit collection"
  action: 'edit'
  fetchOnLoad: true
  focusType: 'collections'

  events: $.extend
    'click button[name="remove"]': 'onClickRemove'
    New::events

  constructor: ->
    super
    @toBeRemoved = []

  url: ->
    "#{super}/#{@id}"

  onClickRemove: ({target}) ->
    target = $(target)
    id = target.val()
    listItem = target.closest '.subject'

    if id in @toBeRemoved
      @toBeRemoved.splice i, 1 for otherId, i in @toBeRemoved when otherId is id
      listItem.removeClass 'to-be-removed'
      @log "Subject #{id} NOT to be removed"
    else
      @toBeRemoved.push id
      listItem.addClass 'to-be-removed'
      @log "Subject #{id} to be removed"

  onSubmit: (ev) ->
    ev.preventDefault()

    newValues =
      title: @el.find('input[name="title"]').val()
      description: @el.find('textarea[name="description"]').val()

    if @data.keywords
      newValues.keywords = {}
      for item in @keywordList.find '.keyword'
        item = $(item)
        newValues.keywords[item.find('input.tag').val()] = item.find('select.operator').val()
    else
      newValues.subject_ids_to_remove = @toBeRemoved

    Api.put @url(), newValues, (result) =>
      @navigate "collections/#{@id}"


class Collections extends SubStack
  controllers:
    show: Show
    new: New
    edit: Edit
  
  routes:
    '/collections/new': 'new'
    '/collections/new/keywords/*keywords': 'new'
    '/collections/new/:subjectId': 'new'
    '/collections/:focusId': 'show'
    '/collections/:id/edit': 'edit'


module.exports = Collections
