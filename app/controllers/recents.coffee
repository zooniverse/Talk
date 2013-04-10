Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Index extends Page
  className: "#{Page::className} recents"
  template: require('views/recents/index')
  
  elements: $.extend
    '.subjects .list': 'subjectList'
    '.discussions .help.list': 'helpList'
    '.discussions .science.list': 'scienceList'
    '.discussions .chat.list': 'chatList'
    '.collections .list': 'collectionList'
    Page::elements
  
  events: $.extend
    'click button[name="load-more"]': 'loadMore'
    'click [data-link]': 'navTo'
    Page::events
  
  render: ->
    @subjectsPage = 1
    @collectionsPage = 1
    @discussionPages =
      help: 1
      science: 1
      chat: 1
    
    super
  
  url: =>
    "#{ super }/recents"
  
  navTo: (ev) =>
    ev.preventDefault()
    discussion = $(ev.target).closest('.discussion-summary')
    @navigate discussion.data('link')
  
  # TO-DO: refactor this
  loadMore: (ev) =>
    ev.preventDefault()
    target = $(ev.target)
    type = target.data 'type'
    category = target.data 'category'
    
    switch type
      when 'subjects'
        Api.get "#{ @url() }/subjects?page=#{ @subjectsPage += 1 }&per_page=12", (results) =>
          if results.length > 0
            @subjectList.append require('views/recents/subjects')(subjects: results)
          
          if results.length < 12
            target.attr disabled: true
      
      when 'discussions'
        Api.get "#{ @url() }/discussions?category=#{ category }&page=#{ @discussionPages[category] += 1 }&per_page=10", (results) =>
          if results.length > 0
            @["#{ category }List"].append require('views/recents/discussions')(category: category, discussions: results)
          
          if results.length < 10
            target.attr disabled: true
      
      when 'collections'
        Api.get "#{ @url() }/collections?page=#{ @collectionsPage += 1 }&per_page=10", (results) =>
          if results.length > 0
            @collectionList.append require('views/recents/collections')(collections: results, updatedStats: true)
          
          if results.length < 10
            target.attr disabled: true

class Recents extends SubStack
  controllers:
    index: Index
  
  routes:
    '/recent': 'index'
  
  default: 'index'
  className: 'stack recents'


module.exports = Recents
