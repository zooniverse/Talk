{Controller} = require 'spine'
template = require 'views/app_header'

class AppHeader extends Controller
  tagName: 'header'
  className: 'app-header'

  constructor: ->
    super
    @html template

module.exports = AppHeader
