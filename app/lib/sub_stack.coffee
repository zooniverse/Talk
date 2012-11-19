Spine = require 'spine'

class SubStack extends Spine.Stack
  constructor: ->
    for key, value of @routes
      do (key, value) =>
        @routes[key] = =>
          @active()
          @[value].active arguments...
    
    super

module.exports = SubStack
