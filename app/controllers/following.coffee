Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Index extends Page
  className: "#{Page::className} following"
  template: require('views/following/index')
  
  elements: $.extend
    '.subjects .list': 'subjectList'
    '.discussions .list': 'discussionList'
    '.collections .list': 'collectionList'
    Page::elements
  
  events: $.extend
    'click button[name="load-more"]': 'loadMore'
    Page::events
  
  constructor: ->
    @subjectsPage = 1
    @collectionsPage = 1
    @discussionPage = 1
    super
  
  url: =>
    "#{ super }/following"
  
  # TO-DO: refactor this
  loadMore: (ev) =>
    ev.preventDefault()
    target = $(ev.target)
    type = target.data 'type'
    category = target.data 'category'
    
    switch type
      when 'subjects'
        Api.get "#{ @url() }/subjects?page=#{ @subjectsPage += 1 }&per_page=6", (results) =>
          if results.length > 0
            @subjectList.append require('views/subjects/list')(subjects: results)
          
          if results.length < 6
            target.attr disabled: true
      
      when 'discussions'
        Api.get "#{ @url() }/discussions?page=#{ @discussionPage += 1 }&per_page=10", (results) =>
          if results.length > 0
            @discussionList.append require('views/discussions/list')(discussions: results)
          
          if results.length < 10
            target.attr disabled: true
      
      when 'collections'
        Api.get "#{ @url() }/collections?page=#{ @collectionsPage += 1 }&per_page=8", (results) =>
          if results.length > 0
            @collectionList.append require('views/collections/list')(collections: results)
          
          if results.length < 8
            target.attr disabled: true

class Following extends SubStack
  controllers:
    index: Index
  
  routes:
    '/following': 'index'
  
  default: 'index'
  className: 'stack following'


module.exports = Following
