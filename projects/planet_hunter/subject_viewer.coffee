{ Controller } = require 'spine'
$ = require 'jqueryify'
CanvasGraph = require 'lib/canvas-graph'

class PlanetHunterSubjectViewer extends Controller
  @imageIn: (location) -> location?.standard
  @subjectTitle: (subject) -> "Image #{ subject.zooniverse_id }"

  className: "subject-viewer planet-hunter-subject-viewer"
  template: require 'views/subjects/viewer'

  subject: null

  elements:
    'canvas': 'canvas'
    '.canvas-container': 'canvasContainer'

  events:
    'click .quarter': 'onClickQuarter'

  constructor: ->
    super

    @quarterList = Object.keys(@subject.location).sort (a, b) ->
      aQuarter = a.split '-'
      bQuarter = b.split '-'

      if aQuarter[0] is bQuarter[0]
        return aQuarter[1] - bQuarter[1]

      aQuarter[0] - bQuarter[0]

    params = location.hash.slice(1).split('?')

    for param in params
      if param.match('quarter')
        console.log "parm ", param
        @selectedQuarter = param.split("=")[1]

    @selectedQuarter ||= @quarterList[0]

    @html @template @
    @el.appendTo $('.page.focus.subject > header')

    setTimeout =>
      $("[data-quarter=\"#{ @selectedQuarter }\"]").click()

  destroy:=>
    console.log "destroying "

  onClickQuarter: (e) =>
    spinner = new Spinner({width: 3, color: '#fff'}).spin @canvasContainer.get(0)

    $("[data-quarter]").removeClass 'active'

    @selectedQuarter = $(e.currentTarget).data 'quarter'

    if @subject.metadata.synthetic_id?
      $(".simulation_tag").show()
      $(".planet_tag").hide()

      $(".synth_details").show()
      $(".planet_details").hide()

    else if @subject.metadata.known_planet?
      $(".simulation_tag").hide()
      $(".planet_tag").show()

      $(".synth_details").hide()
      $(".planet_details").show()

    else
      $(".simulation_tag").hide()
      $(".planet_tag").hide()

      $(".synth_details").hide()
      $(".planet_details").hide()

    $("[data-quarter=\"#{ @selectedQuarter }\"]").addClass 'active'
    dataFileLocation = @subject.location[@selectedQuarter]

    dataFileLocation = dataFileLocation.replace("http://www.planethunters.org/", "https://s3.amazonaws.com/zooniverse-static/planethunters.org/")


    $.getJSON "#{dataFileLocation}", (data) =>
      spinner.stop()
      @setMetadata(data)

      @graph = new CanvasGraph @el, @canvas.get(0), data

  setMetadata:(data)=>
    meta = @subject.metadata
    console.log "data is ", @data
    data_meta = data.metadata
    $(".meta_type").html(meta.type || "Dwarf")
    $(".meta_kid").html(meta.kepler_id || "unknown")
    $(".meta_temp").html(meta.teff || "unknown")
    $(".meta_mag").html(meta.magnitudes.kepler || "unknown")
    $(".meta_radius").html(meta.radius || "unknown")

    ra = @subject.coords[0]
    dec = @subject.coords[1]

    kepler_id = meta.kepler_id

    $(".old_ph_link").hide()
    $(".ukirt_link").attr("href", "http://surveys.roe.ac.uk:8080/wsa/GetImage?ra=#{ra}&dec=#{dec}&database=wserv4v20101019&frameType=stack&obsType=object&programmeID=10209&mode=show&archive=%20wsa&project=wserv4")
    $(".keptps_link").attr("href", "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?&table=tce&format=ipac_ascii&select=kepid,tce_plnt_num,tce_full_conv,tce_fwm_stat,tce_period,tce_time0bk,tce_ror,tce_dor,tce_num_transits,tce_duration,tce_incl,tce_depth,tce_model_snr,tce_prad,tce_sma,tce_bin_oedp_stat&where=kepid=#{kepler_id}")
    $(".mast_link").attr("href", "http://archive.stsci.edu/kepler/kepler_fov/search.php?kic_kepler_id=#{kepler_id}&selectedColumnsCsv=kic_kepler_id,twomass_2mass_id,twomass_tmid,kic_degree_ra,kic_dec,kct_avail_flag,kic_pmra,kic_pmdec,g,r,i,z,gred,d51mag,j,h,k,kepmag,kic_scpid,kic_altid,kic_teff,kic_logg,kic_feh,kic_ebminusv,kic_av,kic_radius,gr,jk,gk&action=Sea")
    $(".star_prop_link").attr("href", "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?table=q1_q16_stellar&format=bar-delimited&where=kepid=#{kepler_id}")

    if data_meta.synth_no?
      $(".synth_details").show()
      $(".synth_radius").html(data_meta.planet_rad)
      $(".synth_period").html(data_meta.planet_period)
    else
      $(".synth_details").hide()

    if @subject.metadata.known_planet?
      $(".planet_radius").html(@subject.metadata.planet_rad)
      $(".planet_period").html(@subject.metadata.planet_period)
    else
      $(".planet_details").hide()

    if meta.old_zooniverse_ids?
      for quarter_id, q_data of meta.light_curves
        if q_data.quarter == @selectedQuarter
          $(".old_ph_link").show()
          $(".old_ph_link").attr("href", "http://oldtalk.planethunters.org/objects/#{meta.old_zooniverse_ids[quarter_id]}")





module.exports = PlanetHunterSubjectViewer
