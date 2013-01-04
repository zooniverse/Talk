Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Focus = require 'models/focus'
FocusPage = require 'controllers/focus_page'
template = require 'views/subjects/show'
$ = require 'jqueryify'
SubjectViewer = require 'controllers/subject_viewer'

class Show extends FocusPage
  template: template
  className: "#{FocusPage::className} subject page"
  focusType: 'subjects'
  
  elements: $.extend
    '.collections .list': 'collectionsList'
    '.collections .pages': 'paginateLinks'
    FocusPage::elements
  
  reload: (callback) ->
    if @fetchOnLoad
      Focus.fetch @focusId, (@data) =>
        collections = @data.collections
        @data.collections = { }
        
        if collections?.length > 0
          page = 0
          for index in [0 .. collections.length] by 3
            @data.collections[page += 1] = collections.slice index, index + 3
          
          @data.collectionsCount = collections.length
          @data.collectionPages = page
        else
          @data.collectionsCount = 0
          @data.collectionPages = 0
        
        @render()
        callback @data
    else
      super
  
  render: ->
    @subjectViewer?.destroy()
    super
    @subjectViewer = new SubjectViewer el: @el.find('.subject-viewer'), subject: @data
    @log @subjectViewer
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
