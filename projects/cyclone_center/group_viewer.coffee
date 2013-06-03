DefaultGroupViewer = require 'controllers/default_group_viewer'

class CycloneCenterGroupViewer extends DefaultGroupViewer
  className: "#{ DefaultGroupViewer::className } cyclone-center-group-viewer"
  
  @description: (group) -> ''
  @groupTitle: (group) -> "#{ group.name }(#{ group.metadata.year })"

module.exports = CycloneCenterGroupViewer
