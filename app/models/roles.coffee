{ project } = require 'lib/config'
Api = require 'zooniverse/lib/api'

class Roles
  @roles = { }
  @url: "/projects/#{ project }/talk/users/roles"
  
  @fetch: (callback) ->
    Api.get @url, (results) =>
      @roles[user.name] = user.roles for user in results
      callback?()
  
  @hasRole: (name, role) =>
    @roles[name]? and role in @roles[name]


module.exports = Roles
