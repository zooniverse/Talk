SubStack = require 'lib/sub_stack'
FocusPage = require 'controllers/focus_page'
template = require 'views/collections/show'

class Show extends FocusPage
  template: template
  className: 'collection page'
  focusType: 'collections'


class New extends FocusPage
  template: require('views/collections/new')
  fetchOnLoad: false
  
  elements:
    'form.new-collection': 'form'
  
  events:
    'submit form.new-collection': 'createCollection'
  
  url: ->
    "#{ super }/collections"
  
  activate: (params) ->
    return unless params
    super
  
  createBoard: (ev) ->
    ev.preventDefault()
    
    Api.post @url(), @form.serialize(), (result) =>
      @navigate '/collections', result.zooniverse_id


class Collections extends SubStack
  controllers:
    show: Show
    new: New
  
  routes:
    '/collections/:focusId': 'show'


module.exports = Collections
