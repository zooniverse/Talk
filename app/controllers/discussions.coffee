{ focusCollectionFor } = require('lib/util')
Api = require 'zooniverse/lib/api'
Focus = require 'models/focus'
SubStack = require 'lib/sub_stack'
Params = require 'lib/params'
Page = require 'controllers/page'

class DiscussionPage extends Page
  setPage: ->
    @data.currentPage = Params?.page or 1
    comments = @data.comments
    @data.comments = { }
    @data.comments[@data.currentPage] = comments
  
  reload: (callback) ->
    if @fetchOnLoad
      Api.get "#{ @url() }?page=#{ Params?.page or 1 }", (@data) =>
        @focus = @data.focus
        @data.focusType = @discussionFocus()
        @setPage()
        @render()
        callback? @data
    else
      Focus.findOrFetch @focusId, (@focus) =>
        @data = @
        @data.focusType = @focusType
        @setPage()
        
        if @category
          Api.get @boardsUrl(), (@boards) =>
            @render()
            callback? @data
        else
          @render()
          callback? @data
  
  discussionFocus: ->
    return unless @data?.focus?.type
    focusCollectionFor @data.focus.type
  
  focusUrl: ->
    if @data?.focus
      "#{ _super::url() }/#{ @discussionFocus() }/#{ @data.focus._id }"
    else
      "#{ _super::url() }/#{ @focusType }/#{ @focusId }"
  
  boardsUrl: ->
    "#{ _super::url() }/boards"
  
class Show extends DiscussionPage
  template: require('views/discussions/show')
  
  elements: $.extend
    'form.new-comment': 'commentForm'
    'ul.posts': 'commentList'
    '.pages': 'paginateLinks'
    DiscussionPage::elements
  
  events: $.extend
    'submit .new-comment': 'createComment'
    DiscussionPage::events
  
  activate: (params) ->
    return unless params
    { @focusType, @focusId } = params
    @id = params.id.split('?')[0]
    super
  
  url: =>
    "#{ super }/#{ @focusType }/#{ @focusId }/discussions/#{ @id }"
  
  render: ->
    super
    @paginationLinks()
  
  paginationLinks: =>
    return unless @data.comments_count > 10
    @paginateLinks.pagination
      cssStyle: 'light-theme'
      items: @data.comments_count
      itemsOnPage: 10
      onPageClick: @paginateComments
      currentPage: @data.currentPage or 1
  
  paginateComments: (page, ev) =>
    ev.preventDefault()
    Api.get "#{ @url() }/comments", page: page, (comments) =>
      @data.comments[page] = comments
      list = comments.map (comment) ->
        "<li>#{ require('views/discussions/comment') comment: comment }</li>"
      
      @commentList.html list.join("\n")
  
  createComment: (ev) =>
    ev.preventDefault()
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      @commentForm[0].reset()
      comment = require('views/discussions/comment') comment: response
      comment = $("<li>#{ comment }</li>")
      @commentList.append comment


class New extends DiscussionPage
  template: require('views/discussions/new')
  fetchOnLoad: false
  
  elements: $.extend
    'form.new-discussion': 'form'
    DiscussionPage::elements
  
  events: $.extend
    'submit form.new-discussion': 'createDiscussion'
    DiscussionPage::events
  
  url: ->
    "#{ super }/#{ @focusType }/#{ @focusId }/discussions"
  
  activate: (params) ->
    return unless params
    { @category, @focusType, @focusId } = params
    super
  
  createDiscussion: (ev) =>
    ev.preventDefault()
    Api.post @url(), @form.serialize(), (result) =>
      @navigate '', @focusType, @focusId, 'discussions', result.zooniverse_id


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
