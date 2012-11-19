{Controller} = require 'spine'
{ project, apiHost } = require 'lib/config'
Api = require 'zooniverse/lib/api'
$ = require 'jqueryify'

class Page extends Controller
  tagName: 'section'
  className: 'page'

  template: null
  data: null
  
  fetchOnLoad: true
  
  constructor: ->
    super
    @data ?= {}

  activate: (params) ->
    return unless params
    super

    @el.addClass 'loading'
    @reload => @el.removeClass 'loading'

  url: ->
    "/projects/#{ project }/talk"

  reload: (callback) ->
    if @fetchOnLoad
      Api.get @url(), (@data) =>
        @render()
        callback @data
    else
      @data = @
      @render()
      callback? @

  render: ->
    @html @template? @data

module.exports = Page
