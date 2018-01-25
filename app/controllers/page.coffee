{Controller} = require 'spine'
{ project, apiHost } = require '../lib/config'
Api = require 'zooniverse/lib/api'
$ = window.jQuery
ActiveUsers = require './active_users'

class Page extends Controller
  tagName: 'section'
  className: 'page'
  template: null
  data: null
  fetchOnLoad: true
  
  events:
    'click .add-to-collection .collect-this': 'showCollectionList'
    'click .add-to-collection .collection-list .collection': 'collectSubject'
  
  constructor: ->
    super
    @data ?= {}

  activate: (params) ->
    return unless params
    super

    @el.addClass 'loading'
    @reload => @el.removeClass 'loading'

  url: ->
    "/projects/#{ project }/talk"

  reload: (callback) ->
    if @fetchOnLoad
      Api.get @url(), (@data) =>
        @render()
        callback @data
    else
      @data = @
      @render()
      callback? @

  render: ->
    if @activeUsers
      @activeUsers.fetch()
    else
      @activeUsers = new ActiveUsers '.active-users'
    
    @html @template? @data
  
  showCollectionList: (ev) =>
    ev.preventDefault()
    collection = $(ev.target).closest '.add-to-collection'
    list = collection.find '.collection-list'
    subjectId = collection.find('.collect-this').data 'id'
    
    list.addClass 'loading'

    Api.get "/projects/#{ project }/talk/users/collection_list", (results) =>
      list.removeClass 'loading'
      list.show()
      list.html require('../views/users/collection_list') subject: { zooniverse_id: subjectId }, collections: results

  collectSubject: (ev) =>
    ev.preventDefault()
    collectionId = $(ev.target).data 'id'
    collection = $(ev.target).closest '.add-to-collection'
    list = collection.find '.collection-list'
    button = collection.find '.collect-this'
    subjectId = button.data 'id'
    
    Api.post "/projects/#{ project }/talk/collections/#{ collectionId }/add_subject", subject_id: subjectId, (results) =>
      list.html ''
      list.hide()
      button.text 'Collected'

module.exports = Page
