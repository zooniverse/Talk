Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
Message = require 'models/message'
MessageList = require 'controllers/message_list'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Show extends Page
  template: require('views/messages/show')
  
  elements: $.extend
    '.posts': 'messages'
    '.new-message [name="message[body]"]': 'messageBody'
    Page::elements
  
  events: $.extend
    'submit .new-message': 'submit'
    Page::events
  
  activate: (params) ->
    return unless params
    @id = params.id
    super
  
  reload: (callback) ->
    Message.get @id, (@data) =>
      @message = @data
      @render()
      callback? @data
  
  render: ->
    super
    if @messageList
      @messageList.render()
    else
      @messageList = new MessageList('.message-list')
  
  submit: (ev) ->
    ev.preventDefault()

    submitButton = $(ev.target).find '[type="submit"]'
    submitButton.attr disabled: true

    @message.sendReply @messageBody.val(), (@message) =>
      submitButton.attr disabled: false
      @data = @message
      @render()


class New extends Page
  template: require('views/messages/new')
  fetchOnLoad: false
  
  elements: $.extend
    '.new-message': 'form'
    '.new-message .user-search': 'userSearch'
    Page::elements
  
  events: $.extend
    'submit .new-message': 'submit'
    Page::events
  
  render: ->
    super
    if @messageList
      @messageList.render()
    else
      @messageList = new MessageList('.message-list')
    
    @userSearch.autocomplete
      serviceUrl: "#{ Api.host }/#{ Message.url() }/search",
      width: 300
      minChars: 2,
      format: (value, data, currentValue) =>
        """
          <img src="//zooniverse-avatars.s3.amazonaws.com/ouroboros/#{ data.zooniverse_id }" class="avatar" onerror="window.defaultAvatar(this)" />
          #{ @escape(value, currentValue) }
        """
  
  submit: (ev) ->
    ev.preventDefault()

    submitButton = $(ev.target).find '[type="submit"]'
    submitButton.attr disabled: true

    userName = @form.find('[name="user_name"]').val()
    message =
      title: @form.find('[name="message[title]"]').val()
      body: @form.find('[name="message[body]"]').val()
    
    success = =>
      @navigate '/profile'

    failure = (ev) =>
      submitButton.attr disabled: false

      if ev.responseText is 'invalid user'
        alert "#{ @userSearch.val() } is not a valid user"
      else
        alert 'Something went wrong, please try again'
    
    Message.start userName, message, success, failure
  
  escape: (value, currentValue) ->
    escaping = new RegExp "(\\#{ ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') })", 'g'
    value.replace new RegExp("(#{ currentValue.replace escaping, '\\$1' })", 'gi'), '<strong>$1<\/strong>'



class Messages extends SubStack
  controllers:
    new: New
    show: Show
  
  routes:
    '/messages/new': 'new'
    '/messages/:id': 'show'
  
  default: 'new'
  className: 'stack messages'


module.exports = Messages
