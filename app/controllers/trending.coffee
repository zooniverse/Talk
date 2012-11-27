Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'

class Index extends Page
  template: require('views/trending/index')
  
  url: =>
    "#{ super }/trending"

class Trending extends SubStack
  controllers:
    index: Index
  
  routes:
    '/': 'index'
    '/trending': 'index'
  
  default: 'index'
  className: 'stack trending'


module.exports = Trending
