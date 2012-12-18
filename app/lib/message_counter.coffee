Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
Message = require 'models/message'

updateCounter = ->
  clearTimeout(Message.timer) if Message.timer
  if User.current
    Api.get '/talk/messages/count', (count) ->
      User.trigger 'message-count', count
      Message.timer = setTimeout updateCounter, 10000

User.bind 'sign-in', ->
  updateCounter()
