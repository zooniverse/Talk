DefaultGroupViewer = require 'controllers/default_group_viewer'

class CycloneCenterGroupViewer extends DefaultGroupViewer
  className: "#{ DefaultGroupViewer::className } cyclone-center-group-viewer"
  
  @groupName: -> 'Storm'
  
  @description: (group) -> """
    #{ group.name }, #{ group.metadata.year }<br />
    <span class="data-label">Wind:</span><span class="wind-data"></span><br />
    <span class="data-label">Pressure:</span><span class="pressure-data"></span><br />
    <a target="_blank" href="http://atms.unca.edu/ibtracs/ibtracs_v03r04/browse-ibtracs/index.php?name=v03r04-#{ group.metadata.id }">View IBTraCS data</a>
  """
  
  @groupTitle: (group) -> "#{ group.name }(#{ group.metadata.year })"
  
  render: ->
    super
    if @group.metadata.stats.length > 1
      $('.group.page .description .wind-data').sparkline @stats('wind'), type: 'line', width: '80%', tooltipFormat: '{{y}} knots'
      $('.group.page .description .pressure-data').sparkline @stats('pressure'), type: 'line', width: '80%', tooltipFormat: '{{y}} millibars'
    else
      $('.group.page .description .data-label').hide()
  
  stats: (stat) ->
    (@statIn point[stat] for point in @group.metadata.stats)
  
  statIn: (point = { }) ->
    if point.wmo > 0
      point.wmo
    else if point.min > 0 and point.max > 0
      (point.min + point.max) / 2
    else if point.min > 0
      point.min
    else if point.max > 0
      point.max
    else
      0

module.exports = CycloneCenterGroupViewer
