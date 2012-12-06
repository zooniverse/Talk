Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
FocusPage = require 'controllers/focus_page'
template = require 'views/subjects/show'
$ = require 'jqueryify'

class Show extends FocusPage
  template: template
  className: "#{FocusPage::className} subject page"
  focusType: 'subjects'
  
  elements: $.extend
    '.collections .list': 'collectionsList'
    '.collections .pages': 'paginateLinks'
    FocusPage::elements
  
  render: ->
    super
    @collectionPage = 1
    @paginationLinks()
  
  paginationLinks: =>
    return unless @data.collectionPages > 1
    @paginateLinks.pagination
      cssStyle: 'compact-theme'
      items: @data.collectionsCount
      itemsOnPage: 3
      onPageClick: @paginateCollections
  
  paginateCollections: (page, ev) =>
    ev.preventDefault()
    @collectionsList.html require('views/collections/list')(collections: @data.collections[page])


class Subjects extends SubStack
  controllers:
    show: Show
  
  routes:
    '/subjects/:focusId': 'show'


module.exports = Subjects
