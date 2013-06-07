Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Index extends Page
  className: "#{Page::className} recents"
  template: require('views/recents/index')
  
  elements: $.extend
    '.subjects .list': 'subjectList'
    '.groups .list': 'groupList'
    '.discussions .help.list': 'helpList'
    '.discussions .science.list': 'scienceList'
    '.discussions .chat.list': 'chatList'
    '.collections .list': 'collectionList'
    Page::elements
  
  events: $.extend
    'click button[name="load-more"]': 'loadMore'
    'click [data-link]': 'navTo'
    Page::events
  
  constructor: ->
    super
    @data = null
  
  render: ->
    @subjectsPage or= 1
    @groupsPage or= 1
    @collectionsPage or= 1
    @discussionPages or=
      help: 1
      science: 1
      chat: 1
    
    super
  
  url: =>
    "#{ super }/recents"
  
  reload: (callback) ->
    if @data
      callback @data
    else
      Api.get @url(), (data) =>
        @data =
          featured: data.featured
          tags: data.tags
          subjects:
            1: data.subjects
          groups:
            1: data.groups
          discussions:
            help:
              1: data.discussions.help
            science:
              1: data.discussions.science
            chat:
              1: data.discussions.chat
          collections:
            1: data.collections
        
        @render()
        callback @data
  
  navTo: (ev) =>
    ev.preventDefault()
    discussion = $(ev.target).closest '[data-link]'
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
            subjectPage = { subjects: { } }
            subjectPage.subjects[@subjectPage] = results
            @data.subjects[@subjectsPage] = results
            @subjectList.append require('views/recents/subjects')(subjectPage)
          
          if results.length < 12
            target.attr disabled: true
      
      when 'groups'
        Api.get "#{ @url() }/groups?page=#{ @groupsPage += 1 }&per_page=10", (results) =>
          if results.length > 0
            groupPage = { groups: { } }
            groupPage.groups[@groupPage] = results
            @data.groups[@groupsPage] = results
            @groupList.append require('views/recents/groups')(groupPage)
          
          if results.length < 10
            target.attr disabled: true
      
      when 'discussions'
        page = @discussionPages[category] += 1
        Api.get "#{ @url() }/discussions?category=#{ category }&page=#{ page }&per_page=10", (results) =>
          if results.length > 0
            discussionPage = { discussions: { } }
            discussionPage.discussions[page] = results
            @data.discussions[category][page] = results
            @["#{ category }List"].append require('views/recents/discussions')(discussionPage)
          
          if results.length < 10
            target.attr disabled: true
      
      when 'collections'
        Api.get "#{ @url() }/collections?page=#{ @collectionsPage += 1 }&per_page=10", (results) =>
          if results.length > 0
            collectionPage = { collections: { } }
            collectionPage.collections[@collectionsPage] = results
            @collectionList.append require('views/recents/collections')(collectionPage)
          
          if results.length < 10
            target.attr disabled: true

class Recents extends SubStack
  controllers:
    index: Index
  
  routes:
    '/': 'index'
    '/recent': 'index'
  
  default: 'index'
  className: 'stack recents'


module.exports = Recents
