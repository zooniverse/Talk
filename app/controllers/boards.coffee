Spine = require 'spine'
Page = require 'controllers/page'

class Show extends Page
  template: require('views/boards/show')
  activate: (params) ->
    return unless params
    @id = params.id
    super
  
  url: =>
    "#{ super }/boards/#{ @id }"

class Index extends Page
  template: require('views/boards/index')
  
  url: ->
    "#{ super }/boards"


class Boards extends Spine.Stack
  controllers:
    show: Show
    index: Index
  
  routes:
    '/boards': 'index'
    '/boards/:id': 'show'
  
  default: 'index'
  className: 'stack boards'

module.exports = Boards
