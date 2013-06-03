Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
Page = require 'controllers/page'
Focus = require 'models/focus'
FocusPage = require 'controllers/focus_page'
GroupViewer = require 'controllers/group_viewer'

class Show extends FocusPage
  template: require 'views/groups/show'
  className: "#{ FocusPage::className } group page"
  focusType: 'groups'
  
  render: ->
    @groupViewer?.destroy()
    super
    @groupViewer = new GroupViewer el: @el.find('.group-viewer'), group: @data
  
  reload: (callback) ->
    if @fetchOnLoad
      Focus.fetch @focusId, (@data) =>
        @render()
        callback @data
    else
      super


class Groups extends SubStack
  controllers:
    show: Show
  
  routes:
    '/groups/:focusId': 'show'


module.exports = Groups
