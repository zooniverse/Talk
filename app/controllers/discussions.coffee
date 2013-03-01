{ focusCollectionFor } = require('lib/util')
Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
Focus = require 'models/focus'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'
Params = require 'lib/params'

class DiscussionPage extends Page
  elements: $.extend
    '.subjects .list': 'subjectsList'
    '.subjects .pages': 'paginateSubjectLinks'
    Page::elements
  
  setPage: ->
    @data.currentPage = Params.parse()?.page or 1
    comments = @data.comments
    @data.comments = { }
    @data.comments[@data.currentPage] = comments
  
  reload: (callback) ->
    if @fetchOnLoad
      Api.get "#{ @url() }?page=#{ Params.parse()?.page or 1 }", (@data) =>
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
      img.src = require('controllers/subject_viewer').imageIn(subject?.location)
  
class Show extends DiscussionPage
  template: require('views/discussions/show')
  
  elements: $.extend
    'form.new-comment': 'commentForm'
    'ul.posts': 'commentList'
    '.pages': 'paginateLinks'
    '.discussion-topic .respond h4 .in-response-to': 'inResponseTo'
    '.post header .title': 'title'
    '.discussion .board-categories': 'boardCategories'
    '.actions': 'actions'
    DiscussionPage::elements
  
  events: $.extend
    'click .discussion-topic .post .comment-moderation .edit-comment': 'editComment'
    'click .discussion-topic .post .respond-link': 'respondTo'
    'click .discussion-topic .in-response-to .remove': 'removeRespondTo'
    'click .discussion-topic .post .response-to': 'toggleResponse'
    'submit .new-comment': 'createComment'
    'submit .edit-comment': 'updateComment'
    'click .feature-link button': 'featureDiscussion'
    'click .actions .destroy.action': 'destroyDiscussion'
    'click .actions .edit.action': 'editDiscussion'
    'click .actions .update.action': 'updateDiscussion'
    'submit .edit-discussion-title': 'updateDiscussion'
    'submit .edit-discussion-categories': 'updateDiscussion'
    'click .actions .cancel-update.action': 'stopEditingDiscussion'
    'change .edit-discussion-categories .category': 'showSubBoards'
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
    if commentId = Params.parse().comment_id
      doc = $('html, body')
      comment = $("##{ commentId }")
      doc.animate
        scrollTop: comment.offset().top - doc.offset().top + doc.scrollTop()
  
  paginationLinks: =>
    return unless @data.comments_count > 10
    @paginateLinks.pagination
      cssStyle: 'light-theme'
      items: @data.comments_count
      itemsOnPage: 10
      onPageClick: @paginateComments
      currentPage: @data.currentPage or 1
  
  paginateComments: (page, ev, callback) =>
    ev?.preventDefault()
    Api.get "#{ @url() }/comments", page: page, (comments) =>
      @callback? comments
      @data.comments[page] = comments
      list = comments.map (comment) =>
        "<li>#{ require('views/discussions/comment') discussionId: @data.zooniverse_id, comment: comment }</li>"
      
      @commentList.html list.join("\n")
  
  respondTo: (ev) =>
    ev.preventDefault()
    id = $(ev.target).data('id')
    @commentForm.find('input[name="response_to_id"]').val id
    comment = @findComment id
    @inResponseTo.html """In response to #{ comment.user_name }'s comment (<a class="remove">cancel</a>)"""
    @setCommentCursor()
  
  removeRespondTo: (ev) =>
    ev.preventDefault()
    @commentForm.find('input[name="response_to_id"]').val ''
    @inResponseTo.html ''
    @setCommentCursor()
  
  toggleResponse: (ev) =>
    ev.preventDefault()
    el = $(ev.target).closest('.post:not(.response-post)')
    id = el.attr 'id'
    comment = @findComment id
    
    toggle = (comment) =>
      responseEl = $(""".response-post[data-comment-id="#{ comment._id }"]""")
      if responseEl[0]
        responseEl.remove()
      else
        el.before require('views/discussions/response')(comment: comment)
    
    if comment
      toggle comment
    else
      Api.get "#{ Page::url() }/discussions/#{ @data.zooniverse_id }/comments/#{ id }", toggle
  
  setCommentCursor: ->
    box = $('#wmd-inputcomment').focus()[0]
    if typeof box.selectionStart is 'number'
      box.selectionStart = box.selectionEnd = box.value.length
    else if typeof box.createTextRange isnt 'undefined'
      box.focus()
      range = box.createTextRange()
      range.collapse false
      range.select()
  
  createComment: (ev) =>
    ev?.preventDefault()
    return false if @commentForm.find('[name="comment"]').val().trim().length < 1
    
    submitButton = $(ev.target).find '[type="submit"]'
    submitButton.attr disabled: true
    
    Api.post "#{ @url() }/comments", @commentForm.serialize(), (response) =>
      submitButton.attr disabled: false
      @inResponseTo.html ''
      @commentForm[0].reset()
      preview = @commentForm.find '#wmd-previewcomment'
      preview.html ''
      @commentForm.find('.toggle-preview').click() if preview.is(':visible')
      @data.comments_count += 1
      @paginationLinks()
      lastPage = Math.ceil(@data.comments_count / 10.0)
      
      if lastPage > 1
        @paginateLinks.pagination 'selectPage', lastPage
      else
        comment = require('views/discussions/comment') discussionId: @data.zooniverse_id, comment: response
        comment = $("<li>#{ comment }</li>")
        @commentList.append comment
  
  editComment: (ev) =>
    ev.preventDefault()
    target = $(ev.target)
    id = target.data 'comment-id'
    comment = @findComment id
    commentEl = target.closest '.post'
    commentEl.html require('views/discussions/edit_comment_form')(discussionId: @data.zooniverse_id, comment: comment)
    commentEl.find('textarea').val comment.body
  
  updateComment: (ev) =>
    ev.preventDefault()
    target = $(ev.target).find('[type="submit"]')
    { commentId, discussionId } = target.data()
    formEl = target.closest '.edit-comment'
    body = formEl.find('[name="comment"]').val()
    
    Api.put "#{ Page::url() }/discussions/#{ discussionId }/comments/#{ commentId }", body: body, =>
      comment = @findComment commentId
      comment.body = body
      formEl.closest('.post').replaceWith require('views/discussions/comment')(discussionId: discussionId, comment: comment)
  
  findComment: (id) =>
    for page, comments of @data.comments
      comment = comments.filter((c) -> c._id is id)[0]
      if comment
        comment.discussionPage = page
        return comment
    null
  
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
  
  destroyDiscussion: (ev) =>
    ev.preventDefault()
    if confirm('Are you sure you want to remove this discussion?\nThere is no undo!')
      Api.delete @url(), =>
        @navigate '/boards', @data.board._id
  
  editDiscussion: (ev) =>
    ev.preventDefault()
    @actions.addClass 'editing'
    @title.html require('views/discussions/edit_title')(@data)
    
    if User.current.isPrivileged
      Api.get @boardsUrl(), (boards) =>
        @data.boardCategories = boards
        @boardCategories.html require('views/discussions/edit_categories')(@data)
  
  showSubBoards: (ev) =>
    ev.preventDefault()
    category = $(ev.target).find('option:selected').val()
    subBoards = $('.edit-discussion-categories .sub-board')
    subBoards.attr 'data-category', category
    subBoards.prop 'selectedIndex', -1
  
  updateDiscussion: (ev) =>
    ev.preventDefault()
    input = @title.find 'input'
    changes = { title: input.val() }
    
    categoryValid = true
    if User.current.isPrivileged
      categories = $('.edit-discussion-categories')
      changes['board'] = categories.find('.sub-board :selected').val()
      categoryValid = categories.find('.sub-board')[0].checkValidity()
      
      unless categoryValid
        categories.find('[type=submit]').click()
        return
    
    if input[0].checkValidity()
      Api.put @url(), changes, (@data) =>
        @stopEditingDiscussion(ev)
    else
      $('.edit-discussion-title [type=submit]').click()
  
  stopEditingDiscussion: (ev) =>
    ev?.preventDefault()
    @actions.removeClass 'editing'
    @title.html @data.title
    @boardCategories.html require('views/discussions/board_categories')(@data)


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

    submitButton = $(ev.target).find '[type="submit"]'
    submitButton.attr disabled: true

    Api.post @url(), @form.serialize(), (result) =>
      @navigate '/boards', result.board._id, 'discussions', result.zooniverse_id


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
