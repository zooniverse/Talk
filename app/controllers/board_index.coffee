{ project, apiHost } = require 'lib/config'
Api = require 'zooniverse/lib/api'
$ = require 'jqueryify'
Page = require 'controllers/page'
template = require 'views/boards/index'

class BoardIndex extends Page
  template: template
  className: 'board page'
  
  url: ->
    "#{ super }/boards"
  

module.exports = BoardIndex
