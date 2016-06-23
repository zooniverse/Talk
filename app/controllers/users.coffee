Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'
Message = require 'models/message'
MessageList = require 'controllers/message_list'

class Profile extends Page
  className: "#{Page::className} user"
  template: require('views/users/profile')
  
  events: $.extend
    'click .subjects .load-more button': 'loadMore'
    'click .groups .load-more button': 'loadMore'
    'click .collections .load-more button': 'loadMore'
    'click .boards .load-more button': 'loadMore'
    'click .my_collections .load-more button': 'loadMore'
    Page::events
  
  constructor: ->
    @sections =
      groups:
        page: 1
        perPage: 6
        template: 'views/users/group_comments'
        argument: 'groups'
      
      subjects:
        page: 1
        perPage: 6
        template: 'views/users/subject_comments'
        argument: 'subjects'
      
      collections:
        page: 1
        perPage: 6
        template: 'views/users/collection_comments'
        argument: 'collections'
      
      boards:
        page: 1
        perPage: 15
        template: 'views/discussions/list'
        argument: 'discussions'
      
      my_collections:
        page: 1
        perPage: 8
        template: 'views/collections/list'
        argument: 'collections'
    
    super
    
  url: =>
    "#{ super }/users/profile"
  
  reload: (callback) =>
    Api.get @url(), (@data) =>
      @data.sections = @sections
      @render()
      callback @data
  
  render: =>
    super
    if @messageList
      @messageList.viewedUser = @id
      @messageList.render()
    else if User.current
      @messageList = new MessageList('.message-list', @id)
  
  loadMore: (ev) =>
    ev.preventDefault()
    target = $(ev.target)
    type = target.data 'type'
    page = @sections[type].page += 1
    section = @sections[type]
    
    Api.get "#{ @url() }?type=#{ type }&page=#{ page }", (results) =>
      results = results[type]
      if results.length > 0
        params = { }
        params[section.argument] = results
        $(".#{ type } .list").append require(section.template)(params)
      
      if results.length < section.perPage
        target.attr disabled: true


class Show extends Profile
  template: require('views/users/show')
  
  url: =>
    "#{ Page::url() }/users/#{ @id }"
  
  activate: (params) ->
    return unless params
    @id = params.id
    super
  
  render: =>
    @data.user = { name: @id, zooniverse_id: @data.zooniverse_id, avatar: @data.avatar, state: @data.talk?.state }
    super


class Preferences extends Profile
  template: require('views/users/preferences')
  fetchOnLoad: false
  
  events: $.extend
    'change .preference': 'changePreference'
    Page::events
  
  reload: ->
    @render()
  
  changePreference: (ev) =>
    ev.preventDefault()
    target = $(ev.target)
    preference = target.closest '.row'
    key = target.attr 'name'
    value = target.val()
    preference.find('.description').hide()
    preference.find(".description[name='#{ value }']").show()
    
    Api.put '/users/preferences', key: "talk.#{ key }", value: value, =>
      User.current.preferences or= { }
      User.current.preferences.talk or= { }
      User.current.preferences.talk[key] = value
      @messageList.render()


class Users extends SubStack
  controllers:
    show: Show
    profile: Profile
    preferences: Preferences
  
  routes:
    '/profile': 'profile'
    '/users/profile': 'profile'
    '/users/preferences': 'preferences'
    '/users/:id': 'show'
  
  default: 'profile'
  className: 'stack users'


module.exports = Users
