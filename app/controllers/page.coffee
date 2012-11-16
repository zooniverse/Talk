{Controller} = require 'spine'
$ = require 'jqueryify'

class Page extends Controller
  tagName: 'section'
  className: 'page'

  template: null
  data: null

  resourceId: ''

  constructor: ->
    super
    @data ?= {}

  activate: ->
    super

    @el.addClass 'loading'
    @reload => @el.removeClass 'loading'

  url: ->
    ''

  reload: (callback) ->
    $.get @url(), (@data) =>
      @render()
      callback @data

  render: ->
    @html @template? @data

module.exports = Page
