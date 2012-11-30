{ project } = require 'lib/config'
Api = require 'zooniverse/lib/api'

class Roles
  @queue: []
  @fetched: false
  @roles = { }
  @url: "/projects/#{ project }/talk/users/roles"
  
  @fetch: ->
    Api.get @url, (results) =>
      @roles[user.name] = user.roles for user in results
      @fetched = true
      @hasRole(enqueued...) for enqueued in @queue
  
  @hasRole: (name, role, callback) =>
    if @fetched
      callback @roles[name]? and role in @roles[name]
    else
      @queue.push [name, role, callback]


module.exports = Roles
