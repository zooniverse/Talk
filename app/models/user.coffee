Api = require 'zooniverse/lib/api'
project = require('lib/config').project


class User
  @get: (name, callback) =>
    Api.get @url(name), (user) =>
      callback? user

  @url: (name) ->
    "/projects/#{project}/talk/users/#{name}"


module.exports = User
