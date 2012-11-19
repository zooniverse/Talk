{ Controller } = require 'spine'
{ project, apiHost } = require 'lib/config'
Api = require 'zooniverse/lib/api'
$ = require 'jqueryify'

class BoardCategory extends Spine.Controller
  className: 'board'
  

module.exports = BoardCategory
