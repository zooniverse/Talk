Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Show extends Page
  template: require('views/boards/show')
  
  elements: $.extend
    'form.new-discussion': 'discussionForm'
    '.discussions .list': 'discussionsList'
    '.discussions .pages': 'paginateDiscussionLinks'
    Page::elements
  
  events: $.extend
    'submit .new-discussion': 'createDiscussion'
    Page::events
  
  activate: (params) ->
    return unless params
    @id = params.id
    super
  
  url: =>
    "#{ super }/boards/#{ @id }"
  
  render: ->
    @data.currentPage = 1
    
    nonfeatured = []
    featuredIds = @data.featured.map (d) -> d.zooniverse_id
    for discussion in @data.discussions when discussion.zooniverse_id not in featuredIds
      nonfeatured.push(discussion)
    
    @data.discussions = { }
    @data.discussions[@data.currentPage] = nonfeatured
    super
    @discussionPaginationLinks()
  
  discussionPaginationLinks: =>
    return unless @data.discussions_count > 10
    @paginateDiscussionLinks.pagination
      cssStyle: 'light-theme'
      items: @data.discussions_count
      itemsOnPage: 10
      onPageClick: @paginateDiscussions
  
  paginateDiscussions: (page, ev) =>
    ev.preventDefault()
    Api.get "#{ @url() }?page=#{ page }", (board) =>
      discussions = board.discussions
      @data.currentPage = page
      @data.discussions[page] = discussions
      @discussionsList.html require('views/boards/discussion_list')(discussions: @data.discussions[page], featured: @data.featured, page: page)
  
  createDiscussion: (ev) =>
    ev.preventDefault()
    
    Api.post "#{ @url() }/discussions", @discussionForm.serialize(), (response) =>
      @navigate '/boards', @id, 'discussions', response.zooniverse_id


class Index extends Page
  template: require('views/boards/index')
  
  events: $.extend
    'click button[name="new-board"]': 'newBoard'
    Page::events
  
  url: ->
    "#{ super }/boards"
  
  newBoard: ({ target }) ->
    category = $(target).val()
    @navigate '/boards', category, 'new'


class New extends Page
  template: require('views/boards/new')
  fetchOnLoad: false
  
  elements: $.extend
    'form.new-board': 'form'
    Page::elements
  
  events: $.extend
    'submit form.new-board': 'createBoard'
    Page::events
  
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
