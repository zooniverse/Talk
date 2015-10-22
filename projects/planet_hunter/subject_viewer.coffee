$ = require 'jqueryify'
{ Controller } = require 'spine'
NoUiSlider     = require 'lib/jquery.nouislider.min'
CanvasGraph    = require 'lib/canvas-graph'

K2_GROUP_IDS = ['547d05ce415ac13139000001','54f4c5ab8f165b6e85000001','55db0eca05cd210084000001', '5628a593eaad4a0122000001']

class PlanetHunterSubjectViewer extends Controller
  @imageIn: (location) -> "https://raw.githubusercontent.com/zooniverse/Brand/master/projects/planethunters.org/avatar.jpg"
  @subjectTitle: (subject) -> "Image #{ subject.zooniverse_id }"

  className: "subject-viewer planet-hunter-subject-viewer"
  template: require 'views/subjects/viewer'

  subject: null

  elements:
    'canvas': 'canvas'
    '.canvas-container': 'canvasContainer'

  events:
    'click .quarter': 'onClickQuarter'
    'click button[id="zoom-button"]': 'onClickZoom'
    'slide #ui-slider': 'onChangeScaleSlider'

  constructor: ->
    super
    @quarterList = Object.keys(@subject.location).sort (a, b) ->
      aQuarter = a.split '-'
      bQuarter = b.split '-'

      if aQuarter[0] is bQuarter[0]
        return aQuarter[1] - bQuarter[1]

      aQuarter[0] - bQuarter[0]

    params = location.hash.slice(1).split('?')

    @isK2Subject = (K2_GROUP_IDS.indexOf(@subject.group_id) > -1)

    for param in params
      if param.match('quarter')
        @selectedQuarter = param.split("=")[1]

    @selectedQuarter ||= @quarterList[0]

    @html @template @
    @el.appendTo $('.page.focus.subject > header')

    setTimeout =>
      $("[data-quarter=\"#{ @selectedQuarter }\"]").click()

  destroy: ->
    @el.off()

  onClickQuarter: (e) =>
    spinner = new Spinner({width: 3, color: '#fff'}).spin @canvasContainer.get(0)

    $("[data-quarter]").removeClass 'active'

    @selectedQuarter = $(e.currentTarget).data 'quarter'

    $("[data-quarter=\"#{ @selectedQuarter }\"]").addClass 'active'
    dataFileLocation = @subject.location[@selectedQuarter]


    if not @isK2Subject
      dataFileLocation = dataFileLocation.replace("http://www.planethunters.org/", "https://s3.amazonaws.com/zooniverse-static/planethunters.org/")

    $.getJSON "#{dataFileLocation}", (data) =>
      spinner.stop()
      @setMetadata(data)
      @graph = new CanvasGraph @el, @canvas.get(0), data

      # reset slider
      $("#ui-slider").noUiSlider
        start: 0
        range:
          min: @graph.smallestX
          max: @graph.largestX #- @zoomRange
      , true

      @graph.zoomOut()
      @graph.disableMarking()

  onClickZoom: ->
    # increment zoom level
    @graph.zoomLevel += 1

    @graph.sliderValue = +$('#ui-slider').val()
    offset = @graph.sliderValue

    # reset zoom
    if @graph.zoomLevel > 2
      @graph.zoomLevel = 0

    if @graph.zoomLevel is 0
      @graph.zoomOut()
    else
      if offset is 0
        @graph.zoomToCenter(@graph.zoomRanges[@graph.zoomLevel] / 2)
      else
        @graph.zoomToCenter(@graph.graphCenter)

      # rebuild slider
      $('#ui-slider').noUiSlider
        start: 0
        range:
          'min': @graph.smallestX,
          'max': @graph.largestX - @graph.zoomRanges[@graph.zoomLevel]
      , true

    @updateZoomButton(@graph.zoomLevel)

  onChangeScaleSlider: ->
    @graph.sliderValue = +@el.find("#ui-slider").val()
    @graph.plotPoints( @graph.sliderValue, @graph.sliderValue + @graph.zoomRanges[@graph.zoomLevel] )

    # update center point
    @graph.graphCenter = (@graph.zoomRanges[@graph.zoomLevel]/2)+@graph.sliderValue

  updateZoomButton: (zoomLevel) ->
    if zoomLevel is 2
      $('#ui-slider').removeAttr('disabled')
      $("#zoom-button").addClass("zoomed")
      $("#zoom-button").addClass("allowZoomOut")
    else if zoomLevel is 1
      $('#ui-slider').removeAttr('disabled')
      $("#zoom-button").addClass("zoomed")
      $("#zoom-button").removeClass("allowZoomOut")
    else
      $('#ui-slider').attr('disabled', true)
      $("#zoom-button").removeClass("zoomed")

  setMetadata: (data) =>
    meta = @subject.metadata
    data_meta = data.metadata

    if @isK2Subject
      window.sub = @subject.location

      $(".epic").html(meta["kepler_id"] || meta["EPIC_number"] || "unknown")
      $(".meta_2mass_id").html(meta["2mass_id"] || "unknown")
      $(".meta_sdss_id").html(meta["sdss_id"] || "unknown")
      $(".meta_mag").html(meta.magnitudes.kepler || "unknown")
      $(".meta_hmag").html(meta.magnitudes.Hmag || "unknown")
      $(".meta_jmag").html(meta.magnitudes.Jmag || "unknown")
      $(".meta_kmag").html(meta.magnitudes.Kmag || "unknown")

      $(".k1Metadata").hide()
      $(".k2Metadata").show()
      $(".links").hide()

    else

      $(".meta_type").html(meta.type || "Dwarf")
      $(".meta_kid").html(meta.kepler_id || "unknown")
      $(".meta_temp").html(meta.teff || "unknown")
      $(".meta_mag").html(meta.magnitudes.kepler || "unknown")
      $(".meta_radius").html(meta.radius || "unknown")
      $(".k1Metadata").show()
      $(".k2Metadata").hide()
      $(".links").show()

    [ra, dec] = @subject.coords

    kepler_id = meta.kepler_id

    $(".old_ph_link").hide()
    $(".ukirt_link").attr("href", "http://surveys.roe.ac.uk:8080/wsa/GetImage?ra=#{ra*15}&dec=#{dec}&database=wserv4v20101019&frameType=stack&obsType=object&programmeID=10209&mode=show&archive=%20wsa&project=wserv4")
    $(".keptps_link").attr("href", "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=tce&format=ipac_ascii&select=kepid,tce_plnt_num,tce_full_conv,tce_fwm_stat,tce_period,tce_time0bk,tce_ror,tce_dor,tce_num_transits,tce_duration,tce_incl,tce_depth,tce_model_snr,tce_prad,tce_sma,tce_bin_oedp_stat&where=kepid=#{kepler_id}")
    $(".mast_link").attr("href", "http://archive.stsci.edu/kepler/kepler_fov/search.php?kic_kepler_id=#{kepler_id}&selectedColumnsCsv=kic_kepler_id,twomass_2mass_id,twomass_tmid,kic_degree_ra,kic_dec,kct_avail_flag,kic_pmra,kic_pmdec,g,r,i,z,gred,d51mag,j,h,k,kepmag,kic_scpid,kic_altid,kic_teff,kic_logg,kic_feh,kic_ebminusv,kic_av,kic_radius,gr,jk,gk&action=Search")
    $(".star_prop_link").attr("href", "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?table=q1_q16_stellar&format=bar-delimited&where=kepid=#{kepler_id}")

    if data_meta.syth_no?
      $('.synth-radius').html(data_meta.planet_rad)
      $('.synth-period').html(data_meta.planet_period)
    else if @subject.metadata.known_planet?
      $('.synth-radius').html(@subject.metadata.planet_rad)
      $('.synth-period').html(@subject.metadata.planet_period)
    else
      $('.planet-details').hide()
      $(".synth-details").hide()

    if meta.old_zooniverse_ids?
      for quarter_id, q_data of meta.light_curves
        if q_data.quarter == @selectedQuarter
          $(".old_ph_link").show()
          $(".old_ph_link").attr("href", "http://oldtalk.planethunters.org/objects/#{meta.old_zooniverse_ids[quarter_id]}")

module.exports = PlanetHunterSubjectViewer
