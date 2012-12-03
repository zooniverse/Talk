Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Profile extends Page
  template: require('views/users/profile')
  
  url: =>
    "#{ super }/users/profile"
  


class Show extends Profile
  template: require('views/users/show')
  
  url: =>
    "#{ super }/users/#{ @id }"
  
  activate: (params) ->
    return unless params
    @id = params.id
    super


class Users extends SubStack
  controllers:
    show: Show
    profile: Profile
  
  routes:
    '/profile': 'profile'
    '/users/profile': 'profile'
    '/users/:id': 'show'
  
  default: 'profile'
  className: 'stack users'


module.exports = Users
