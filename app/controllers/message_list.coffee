Message = require 'models/message'

class MessageList
  constructor: (@selector, @viewedUser) ->
    Message.fetch @render
  
  render: (conversations) =>
    @conversations = conversations if conversations
    $(@selector).html require('views/messages/list') conversations: @conversations, viewedUser: @viewedUser

module.exports = MessageList
