Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
Message = require '../models/message'
MessageList = require './message_list'
SubStack = require '../lib/sub_stack'
Page = require './page'

class Index extends Page
  template: require('../views/moderation/index')
  
  events: $.extend
    'click .load-more button': 'loadMore'
    'click .comment-viewer .off': 'toggleComment'
    'click .actions .action-link': 'action'
    Page::events
  
  constructor: ->
    super
    @reported_users =
      page: 1
      actions: ['ignore', 'watch', 'ban']
    
    @watched_users =
      page: 1
      actions: ['unwatch', 'ban']
    
    @banned_users =
      page: 1
      actions: ['redeem']
    
    @reported_comments =
      page: 1
      actions: ['ignore', 'delete']
    
    @log =
      page: 1
      actions: []
  
  url: ->
    "#{ super }/moderation"
  
  render: =>
    @data.pastTenses = @pastTenses()
    super
  
  loadMore: (ev) =>
    ev.preventDefault()
    { type, kind } = $(ev.target).data()
    
    Api.get "#{ @url() }/#{ type }?page=#{ @[type].page += 1 }", (response) =>
      @viewFor type, kind, response
      button = @el.find ".#{ type } .load-more button"
      button.attr('disabled', 'disabled') if response.length < 10
  
  toggleComment: (ev) ->
    ev.preventDefault()
    $(ev.target).closest('.comment-viewer').toggleClass 'on'
  
  action: (ev) =>
    ev.preventDefault()
    target = $(ev.target)
    { id, action, userName } = target.data()
    
    if message = prompt('Please enter a brief message:')
      target.closest('.moderation-item').remove()
      body = { label: action, comment: message }
      body.user_name = userName if userName
      Api.post "#{ @url() }/#{ id }/action", body, (response) =>
        switch action
          when 'ban'
            @viewFor 'banned_users', 'users', response, 'prepend'
          when 'watch'
            @viewFor 'watched_users', 'users', response, 'prepend'
          else
            @viewFor 'log', 'log', response, 'prepend'
  
  viewFor: (type, kind, records, method = 'append') =>
    records = [].concat records
    html = require("views/moderation/#{ kind }") pastTenses: @pastTenses(), moderations: records, actions: @[type].actions
    @el.find(".#{ type } .list")[method] html
  
  pastTenses: ->
    tenses =
      delete: 'deleted'
      delete_comment: 'deleted'
      ban: 'banned'
      ban_user: 'banned'
      watch: 'watched'
      watch_user: 'watched'
      unwatch: 'unwatched'
      unwatch_user: 'unwatched'
      redeem: 'redeemed'
      redeem_user: 'redeemed'
      report: 'reported'
      report_user: 'reported'
      report_comment: 'reported'
      ignore: 'ignored'

class Moderation extends SubStack
  controllers:
    index: Index

  routes:
    '/moderation': 'index'

  default: 'index'
  className: 'stack moderation'


module.exports = Moderation
