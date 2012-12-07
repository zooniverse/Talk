Message = require 'models/message'

class MessageList
  constructor: (@selector) ->
    Message.fetch @render
  
  render: (conversations) =>
    @conversations = conversations if conversations
    $(@selector).html require('views/messages/list') conversations: @conversations

module.exports = MessageList
