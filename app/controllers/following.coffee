Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

# TO-DO: refactor this to share code with Trending
class Index extends Page
  template: require('views/following/index')
  
  elements:
    '.subjects .list': 'subjectList'
    '.discussions .help.list': 'helpList'
    '.discussions .science.list': 'scienceList'
    '.discussions .chat.list': 'chatList'
    '.collections .list': 'collectionList'
  
  events:
    'click button[name="load-more"]': 'loadMore'
  
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
          
          if results.length < 3
            target.attr disabled: true
      
      when 'discussions'
        Api.get "#{ @url() }/discussions?page=#{ @discussionPage += 1 }&per_page=10", (results) =>
          if results.length > 0
            @["#{ category }List"].append require('views/discussions/list')(category: category, discussions: results)
          
          if results.length < 5
            target.attr disabled: true
      
      when 'collections'
        Api.get "#{ @url() }/collections?page=#{ @collectionsPage += 1 }&per_page=8", (results) =>
          if results.length > 0
            @collectionList.append require('views/collections/list')(collections: results)
          
          if results.length < 3
            target.attr disabled: true

class Following extends SubStack
  controllers:
    index: Index
  
  routes:
    '/following': 'index'
  
  default: 'index'
  className: 'stack following'


module.exports = Following
