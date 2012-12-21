Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
{ project } = require 'lib/config'

class ActiveUsers
  constructor: (@selector) ->
    @fetch()
    User.unbind 'sign-in', @fetch
    User.bind 'sign-in', @fetch
  
  fetch: =>
    Api.get "/projects/#{ project }/talk/users/active", @render
  
  render: (@data) =>
    @paginateData()
    $(@selector).html require('views/users/active') @data
    @pagination()
  
  paginateData: =>
    users = @data.users
    @data.users = { }
    
    if users?.length > 0
      page = 0
      for index in [0 .. users.length] by 10
        @data.users[page += 1] = users.slice index, index + 10
      
      @data.usersCount = users.length
      @data.userPages = page
    else
      @data.usersCount = 0
      @data.userPages = 0
  
  pagination: =>
    return unless @data.usersCount > 10
    $('.pages', @selector).pagination
      cssStyle: 'compact-theme'
      items: @data.usersCount
      itemsOnPage: 10
      onPageClick: @paginate
  
  paginate: (page, ev) =>
    ev.preventDefault()
    $('.list', @selector).html require('views/users/active_list')(users: @data.users[page])


module.exports = ActiveUsers
