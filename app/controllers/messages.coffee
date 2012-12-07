Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
Message = require 'models/message'

SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Show extends Page
  template: require('views/messages/show')
  
  activate: (params) ->
    return unless params
    @id = params.id
    super
  
  reload: (callback) ->
    Message.show @id, (@data) =>
      @render()
      callback? @data



class New extends Page
  template: require('views/messages/new')
  fetchOnLoad: false
  
  elements: $.extend
    '.new-message': 'form'
    '.new-message .user-search': 'userSearch'
    Page::elements
  
  events: $.extend
    'submit .new-message': 'submit'
    Page::elements
  
  render: ->
    super
    @userSearch.autocomplete
      serviceUrl: "#{ Api.host }/#{ Message.url() }/search",
      width: 300
      minChars: 2,
      onSelect: (value, data) =>
        @form.find('[name="user_id"]').val data.id
      format: (value, data, currentValue) =>
        """
          <img src="//zooniverse-avatars.s3.amazonaws.com/ouroboros/#{ data.zooniverse_id }" class="avatar" onerror="window.defaultAvatar(this)" />
          #{ @escape(value, currentValue) }
        """
  
  submit: (ev) ->
    ev.preventDefault()
    userId = @form.find('[name="user_id"]').val()
    message =
      title: @form.find('[name="message[title]"]').val()
      body: @form.find('[name="message[body]"]').val()
    
    Message.start userId, message, =>
      @navigate '/profile'
  
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
