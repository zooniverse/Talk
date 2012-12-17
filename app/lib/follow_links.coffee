{ project } = require 'lib/config'
Api = require 'zooniverse/lib/api'

$(window).on 'click', '.follow-link button', (event) ->
  event.preventDefault()
  link = $(event.target)
  action = link.attr 'name'
  id = link.data 'id'
  type = link.data 'type'
  link.attr 'disabled', 'disabled'
  
  url = "/projects/#{ project }/talk/following/#{ action }"
  hash =
    type: type
    id: id
  
  Api.post url, hash, =>
    followed = action is 'follow'
    link.closest('.follow').replaceWith require('views/follow_button')(id: id, type: type, followed: followed)
