{ focusCollectionFor } = require('lib/util')
Api = require 'zooniverse/lib/api'
Focus = require 'models/focus'
SubStack = require 'lib/sub_stack'
Params = require 'lib/params'
Page = require 'controllers/page'

class DiscussionPage extends Page
  elements: $.extend
    '.subjects .list': 'subjectsList'
    '.subjects .pages': 'paginateSubjectLinks'
    Page::elements
  
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
        @buildPagination()
        @setPage()
        @render()
        callback? @data
    else
      Focus.findOrFetch @focusId, (@focus) =>
        @data = @
        @data.focusType = @focusType
        @buildPagination()
        @setPage()
        
        if @category
          Api.get @boardsUrl(), (@boards) =>
            @render()
            callback? @data
        else
          @render()
          callback? @data
  
  buildPagination: =>
    if @data.focusType is 'collections'
      subjects = @data.focus.subjects
      @data.focus.subjects = { }
      
      if subjects?.length > 0
        page = 0
        for index in [0 .. subjects.length] by 6
          @data.focus.subjects[page += 1] = subjects.slice index, index + 6
        
        @data.focus.subjectsCount = subjects.length
        @data.focus.subjectPages = page
      else
        @data.focus.subjectsCount = 0
        @data.focus.subjectPages = 0
  
  render: ->
    super
    @subjectPage = 1
    @subjectPaginationLinks()
  
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
  
  subjectPaginationLinks: =>
    return unless @data.focus.subjectPages > 1
    @paginateSubjectLinks.pagination
      cssStyle: 'compact-theme'
      items: @data.focus.subjectsCount
      itemsOnPage: 10
      onPageClick: @paginateSubjects
  
  paginateSubjects: (page, ev) =>
    ev.preventDefault()
    @subjectsList.html require('views/collections/subjects_for_discussion')(subjects: @data.focus.subjects[page])
    
    return unless @data.focus.subjects[page + 1]
    for subject in @data.focus.subjects[page + 1]
      img = new Image
      img.src = subject?.location?.standard?[0]
  
class Show extends DiscussionPage
  template: require('views/discussions/show')
  
  elements: $.extend
    'form.new-comment': 'commentForm'
    'ul.posts': 'commentList'
    '.pages': 'paginateLinks'
    DiscussionPage::elements
  
  events: $.extend
    'submit .new-comment': 'createComment'
    'click .feature-link button': 'featureDiscussion'
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
  
  featureDiscussion: (ev) =>
    ev.preventDefault()
    button = $(ev.target)
    { id, scope } = button.data()
    action = button.attr 'name'
    Api.post "#{ @url() }/#{ action }", context: scope, (response) =>
      @data.featured_status or= { }
      @data.featured_status.scopes or= []
      
      if action is 'feature'
        @data.featured_status.scopes.push(scope)
      else
        @data.featured_status.scopes = @data.featured_status.scopes.filter (oldScope) -> oldScope isnt scope
      
      @el.find('.feature-link').replaceWith require('views/discussions/feature_buttons') id: id, featured: @data.featured_status, board: @data.board


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
