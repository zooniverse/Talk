Api = require 'zooniverse/lib/api'
projectName = require('lib/config').projectName

class Message
  @records = { }
  
  @fetch: (callback) =>
    Api.get @url(), (messages) =>
      for message in messages
        @records[message.id] = new Message(message)
      callback? @records
  
  @exists: (id) =>
    !!@records[id]
  
  @get: (id, callback) =>
    Api.get @url(id), (message) =>
      @records[message.id] = new Message(message)
      callback? @records[message.id]
  
  @url: (id) ->
    url = '/talk/messages'
    url += "/#{ id }" if id
    url
  
  @start: (userTo, message, callback, failureCallback) ->
    starter = Api.post @url(), user_name: userTo, message: message
    starter.onSuccess (message) =>
      @records[message.id] = new Message(message)
      callback? @records[message.id]
    
    starter.onFailure(failureCallback) if failureCallback
  
  constructor: (hash) ->
    @_copy_keys_from hash
  
  url: =>
    Message.url @id
  
  reload: (callback) =>
    Message.get id, callback
  
  sendReply: (message, callback) =>
    Api.post "#{ @url() }/reply", message: { body: message, project_name: projectName }, (message) =>
      @_copy_keys_from message
      Message.records[@id] = @
      callback? @
  
  destroy: (callback) =>
    Api.delete @url(), =>
      delete Message.records[@id]
      callback?()
  
  isUnread: (user) =>
    lastRead = if @isSender(user) then @last_read_by.user_from else @last_read_by.user_to
    !lastRead or (@updated_at > lastRead)
  
  isSender: (user) =>
    @user_from.id is user.id
  
  isRecipient: (user) =>
    @user_to.id is user.id

  isTitleBlank: =>
    (typeof @title != 'string') or (/^\s?$/.test @title)
  
  _copy_keys_from: (hash) =>
    for own key, val of hash
      @[key] = val


module.exports = Message
