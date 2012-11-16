Page = require './page'
template = require 'views/object_page'

class ObjectPage extends Page
  className: "object #{Page::className}"
  template: template

  url: ->
    "example-data/subject.json"

module.exports = ObjectPage
