Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Show extends Page
  template: require('views/users/show')
  
  url: =>
    "#{ super }/users/#{ @id }"
  
  activate: (params) ->
    return unless params
    @id = params.id
    super


class Profile extends Page
  template: require('views/users/profile')
  
  url: =>
    "#{ super }/users/profile"


class Users extends SubStack
  controllers:
    show: Show
    profile: Profile
  
  routes:
    '/users/profile': profile
    '/users/:id': show
  
  default: 'profile'
  className: 'stack users'


module.exports = Users
