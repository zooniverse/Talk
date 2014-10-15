config = require 'lib/config'
Api = require 'zooniverse/lib/api'

{ project } = config
roleLabels = config?.app?.roleLabels || {}

# Hard-coded role for Darren. Remove when team role exists on API
zooTeam = ['DZM']

class Roles
  @roles = { }
  @url: "/projects/#{ project }/talk/users/roles"

  @fetch: (callback) ->
    Api.get @url, (results) =>
      for user in results
        @roles[user.name] = ((if role of roleLabels then roleLabels[role] else role) for role in user.roles)
        @roles[user.name] = (role for role in @roles[user.name] when role isnt 'translator')

      for teamMember in zooTeam
        @roles[teamMember] ?= []
        @roles[teamMember].push 'zooniverse-team'

      callback?()

  @hasRole: (name, role) =>
    @roles[name]? and role in @roles[name]

module.exports = Roles
