Message = require 'models/message'
User = require 'models/user'

class MessageList
  constructor: (@selector, @viewedUser) ->

    Message.fetch @render

  render: (conversations) =>
    @users = {}
    @conversations = conversations if conversations
    for id, conversation of @conversations
      for message in conversation.messages
        userName = message.user.name
        User.get userName, (@user) =>
          @users[userName] = @user.avatar

    $(@selector).html require('views/messages/list') conversations: @conversations, viewedUser: @viewedUser

module.exports = MessageList
