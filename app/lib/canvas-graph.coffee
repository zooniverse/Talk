class CanvasGraph
  constructor: ( @el, @canvas, @data) ->
    @leftPadding = 60
    @showAxes    = true
    @ctx = @canvas.getContext('2d')
    @highlights = []
    @pointSize = 4

    @dataLength = Math.min @data.x.length, @data.y.length

    # save raw data points
    @data_raw = {}
    @data_raw.x = @data.x.slice(0)
    @data_raw.y = @data.y.slice(0)

    # apply normalization, outlier removal, etc.
    @processLightcurve()

    # initialize zoom parameters
    @zoomRanges = [@largestX, 10, 2]
    @zoomLevel = 0
    @graphCenter = 5

  disableMarking: ->
    # console.log 'CANVAS GRAPH: disableMarking()'
    @markingDisabled = true

  enableMarking: ->
    # console.log 'CANVAS GRAPH: enableMarking()'
    @markingDisabled = false

    # TODO: should this be in the constructor?
    @marks = new Marks
    window.marks = @marks
    @canvas.addEventListener 'mousedown', (e) => @onMouseDown(e)
    @canvas.addEventListener 'touchstart', (e) => @addMarkToGraph(e)
    @canvas.addEventListener 'mousemove', (e) => @onMouseMove(e) # TODO: FIX (disabled for now)

  onMouseDown: (e) =>
    # debugger
    # console.log 'onMouseDown()'
    xClick = e.pageX - e.target.getBoundingClientRect().left - window.scrollX
    return if xClick < @leftPadding # display line instead
    @addMarkToGraph(e)

  onMouseMove: (e) =>
    # return # DEBUG ONLY: KEEP UNTIL THIS IS FIXED

    return if @markingDisabled
    return if @el.find('#graph').hasClass('is-zooming')
    @sliderValue = +@el.find("#ui-slider").val()
    xClick = e.pageX - e.target.getBoundingClientRect().left - window.scrollX
    yClick = e.pageY - e.target.getBoundingClientRect().top - window.scrollY
    # offset = @sliderValue
    # if @zoomLevel is 0
    #   @plotPoints(0, @zoomRanges[@zoomLevel])
    # else if @zoomLevel is 1
    #   @plotPoints(offset, offset+@zoomRanges[@zoomLevel])
    # else
    #   @plotPoints(@graphCenter-1,@graphCenter+1)

    # # @zoomToCenter(@graphCeter+offset)

    # if xClick < @leftPadding
    #   # draw triangle
    #   w = 10
    #   s = 2*w*Math.tan(@leftPadding)

    #   @ctx.beginPath()
    #   @ctx.moveTo(w,yClick)
    #   @ctx.lineTo(0,yClick+s)
    #   @ctx.lineTo(0,yClick-s)
    #   @ctx.fillStyle = '#FC4542'
    #   @ctx.fill()

    #   @ctx.beginPath()
    #   @ctx.moveTo(w,yClick)
    #   @ctx.lineWidth = 1
    #   @ctx.strokeStyle = 'rgba(252,69,66,0.9)'
    #   @ctx.moveTo( 60, yClick )
    #   @ctx.lineTo( @canvas.width, yClick )
    #   @ctx.moveTo( 0, yClick )
    #   @ctx.lineTo( 10, yClick )
    #   @ctx.stroke()

    #   @ctx.font = '10pt Arial'
    #   @ctx.textAlign = 'left'
    #   @ctx.fillText( @toDataYCoord((-yClick+@canvas.height)).toFixed(4), 15, yClick+5 ) # don't forget to flip y-axis values

  processLightcurve: (removeOutliers=true) ->

    @removeOutliers = removeOutliers

    # @el.find("#ui-slider").val(0) # reset slider value
    # @zoomOut()

    # restore original values
    @data.x = @data_raw.x
    @data.y = @data_raw.y

    # this step is necessary or (top) x-axis breaks
    @smallestX = Math.min @data_raw.x...
    @smallestX = Math.min(@smallestX, @data.metadata.start_time)

    @originalMin = @smallestX
    for x, i in [@data.x...]
      @data.x[i] = x - @smallestX

    if removeOutliers
      @data = @processOutliers(@data_raw, nsigma=4)

    @data.y = @normalize(@data.y)

    # update min/max values
    @smallestX = Math.min @data.x...
    @smallestY = Math.min @data.y...
    @largestX = Math.max  @data.x...
    @largestY = Math.max  @data.y...

    # add padding
    if @largestX < 29
      @largestX = 29

    @plotPoints()

    return

  toggleOutliers: ->
    @removeOutliers = !@removeOutliers
    @processLightcurve(@removeOutliers)
    return

  normalize: (data) ->
    y_new = []
    mean = @mean(data)
    std = @std(data)

    for y, i in [ data... ]
      y_new[i] = (y-1)/(std)
      y_new[i] = y/(mean)

    return y_new

  processOutliers: (data, nsigma) ->
    data_new = {}
    data_new.x = []
    data_new.y = []
    mean = @mean(data.y)
    std = @std(data.y)

    for y, i in [data.y...]
      continue if (y - mean) > (nsigma * std) # skip outlier
      data_new.x.push data.x[i]
      data_new.y.push data.y[i]

    return data_new

  std: (data) ->
    mean = @mean(data)
    sum = 0
    for value in data
      sum = sum + Math.pow( Math.abs(mean-value), 2 )
    return Math.sqrt( sum / data.length )

  mean: (data) ->
    sum = 0
    for value in data
      sum = sum + value
    return sum / data.length

  showFakePrevMarks: () ->
    # console.log 'showFakePrevMarks()'
    @zoomOut()
    maxMarks = 5
    minMarks = 1
    howMany = Math.floor( Math.random() * (maxMarks-minMarks) + minMarks )
    # console.log 'randomly generating ', howMany, ' (fake) marks' # DEBUG
    @generateFakePrevMarks( howMany )
    for entry in [@prevMarks...]
      # console.log '[',entry.xL,',',entry.xR,']' # DEBUG
      @highlightCurve(entry.xL,entry.xR)

  generateFakePrevMarks: (n) ->
    minWid = 0.5 # [days]
    maxWid = 3.0
    xPos = []
    wid = []
    @prevMarks = []
    for i in [0...n]
      wid[i] = Math.random() * ( maxWid - minWid ) + minWid
      xPos[i] = Math.random() * (36-1) + 1
      @prevMarks[i] = { xL: xPos[i]-wid[i]/2, xR: xPos[i]+wid[i]/2 }

  showPrevMarks: ->
    $('#graph-container').addClass('showing-prev-data')
    for entry in [@prevMarks...]
      # console.log '[',entry.xL,',',entry.xR,']' # DEBUG
      @highlightCurve(entry.xL,entry.xR)

  highlightCurve: (xLeft,xRight) ->
    return unless xLeft >= @xMin and xRight <= @xMax
    @highlights.push {'xLeft': xLeft, 'xRight': xRight}
    @plotPoints()

  drawHighlights: ->
    sliderOffset = ( (@xMin) / (@xMax - @xMin) ) * ( @canvas.width-@leftPadding )
    for highlight in [ @highlights... ]
      for i in [0...@dataLength]
        if @data.x[i] >= highlight.xLeft and @data.x[i] <= highlight.xRight
          x = ((+@data.x[i]+@toDays(@leftPadding)-@xMin)/(@xMax-@xMin)) * (@canvas.width-@leftPadding)
          y = ((+@data.y[i]-@yMin)/(@yMax-@yMin)) * @canvas.height
          y = -y + @canvas.height # flip y-values
          @ctx.beginPath()
          @ctx.fillStyle = "rgba(255, 0, 0, 1.0)" #"#fc4541"
          @ctx.strokeStyle = "rgba(255, 0, 0, 1.0)" #"#fc4541"

          continue if x-sliderOffset < 60 # skip if overlap with y-axis
          @ctx.arc(x-sliderOffset, y, @pointSize, 0, 2*Math.PI, false)
          # @ctx.fill()
          @ctx.stroke()
          # @ctx.fillRect(x - sliderOffset, y, 4, 4)

  plotPoints: (xMin = @smallestX, xMax = @largestX, yMin = @smallestY, yMax = @largestY) ->
    @xMin = xMin
    @xMax = xMax
    @yMin = yMin
    @yMax = yMax
    @clearCanvas()

    # get necessary values from classifier
    @sliderValue = +@el.find('#ui-slider').val()

    @drawHighlights()


    # draw points
    for i in [0...@dataLength]
      x = ((+@data.x[i]-xMin)/(xMax-xMin)) * (@canvas.width-@leftPadding)
      continue if x < 0 # don't plot points past margin
      y = ((+@data.y[i]-yMin)/(yMax-yMin)) * @canvas.height
      y = -y + @canvas.height # flip y-values
      @ctx.fillStyle = "#fff" #fc4541"
      @ctx.fillRect( x-@pointSize/2+@leftPadding+1, y-@pointSize/2+1, 2, 2 )

    if $('#graph-container').hasClass('showing-prev-data')
      @showPrevMarks()

    # draw axes
    if @showAxes
      @drawXTickMarks(xMin, xMax)
      @drawYTickMarks(yMin, yMax)

    @scale = (parseFloat(@largestX) - parseFloat(@smallestX)) / (parseFloat(@xMax) - parseFloat(@xMin))
    @rescaleMarks(xMin, xMax)

    return

  rescaleMarks: (xMin, xMax) ->
    # console.log 'RESCALING MARKS.....'
    if @zoomLevel is 0
      @sliderValue = 0
    else
      @sliderValue = +@el.find('#ui-slider').val()

    # draw marks
    if @marks
      for mark in @marks.all
        scaledMin = ( mark.dataXMinRel - xMin ) / (xMax - xMin) * (@canvas.width-@leftPadding) + @leftPadding
        scaledMax = ( mark.dataXMaxRel - xMin ) / (xMax - xMin) * (@canvas.width-@leftPadding) + @leftPadding
        mark.element.style.width = (parseFloat(scaledMax)-parseFloat(scaledMin)) + "px"
        mark.element.style.left = parseFloat(scaledMin) + "px"
        mark.save(scaledMin, scaledMax)

    @scale = (@largestX - @smallestX) / (@xMax - @xMin)
    return

  zoomOut: (callback) ->
    @el.find('#graph').addClass('is-zooming')

    @zoomLevel = 0

    # update slider position
    # @el.find('#ui-slider').val(@graphCenter-@zoomRanges[@zoomLevel]/2)

    # @plotPoints(@smallestX, @largestX)

    [cMin, cMax] = [@xMin, @xMax]
    [wMin, wMax] = [@smallestX, @largestX]

    @el.find("#zoom-button").removeClass("zoomed")
    @el.find("#zoom-button").removeClass("allowZoomOut") # for last zoom level
    @el.find('#ui-slider').attr('disabled',true)
    @el.find('.noUi-handle').fadeOut(150)

    # TODO: broken (a major pain in my ass)
    step = 1.5
    zoom = setInterval (=>

      # gradually expand zooming bounds
      cMin -= step
      if cMin < @smallestX then cMin = @smallestX
      cMax += step
      if cMax > @largestX then cMax = @largestX

      # console.log "[cMin,cMax] = [#{cMin},#{cMax}]"
      @plotPoints(cMin,cMax)

      if cMin <= @smallestX and cMax >= @largestX  # finished zooming
        clearInterval zoom
        @el.find('#graph').removeClass('is-zooming')
        @plotPoints(@smallestX, @largestX)
        unless callback is undefined
          callback.apply()
          @el.find("#zoom-button").removeClass("zoomed")
          @el.find("#zoom-button").removeClass("allowZoomOut") # for last zoom level
          @el.find('#graph').removeClass('is-zooming')
          @el.find('#ui-slider').attr('disabled',true)
          @el.find('.noUi-handle').fadeOut(150)
    ), 30
    return

  zoomToCenter: (center) ->
    @el.find('#graph').addClass('is-zooming')
    @graphCenter = center
    boundL = center - @zoomRanges[@zoomLevel]/2
    boundR = center + @zoomRanges[@zoomLevel]/2

    # ensure zooming within bounds
    if boundL < @smallestX
      boundL = @smallestX
      boundR = @smallestX + @zoomRanges[@zoomLevel]
      # console.log "ENFORCING BOUNDS: [#{boundL},#{boundR}] (exceeded left bound)"

    if boundR > @largestX
      boundR = @largestX
      boundL = @largestX - @zoomRanges[@zoomLevel]
      # console.log "ENFORCING BOUNDS: [#{boundL},#{boundR}] (exceeded right bound)"

    # update slider position
    @el.find('#ui-slider').val(boundL)

    [cMin, cMax] = [@xMin, @xMax]
    zoom = setInterval (=>
      @plotPoints(cMin,cMax)
      @rescaleMarks(cMin,cMax)
      cMin += 1.5 unless cMin >= boundL
      cMax -= 1.5 unless cMax <= boundR
      if cMin >= boundL and cMax <= boundR # when 'animation' is done...
        clearInterval zoom
        @el.find('#graph').removeClass('is-zooming')
        @plotPoints(boundL,boundR)
    ), 30

  # NOT REALLY USED ANYMORE
  zoomInTo: (wMin, wMax) ->
    @el.find('#graph').addClass('is-zooming')
    [cMin, cMax] = [@xMin, @xMax]

    @plotPoints(wMin,wMax)

    # zoom = setInterval (=>
    #   @plotPoints(cMin,cMax)
    #   @rescaleMarks(cMin,cMax)
    #   cMin += 1.5 unless cMin >= wMin
    #   cMax -= 1.5 unless cMax <= wMax
    #   if cMin >= wMin and cMax <= wMax # when 'animation' is done...
    #     clearInterval zoom
    #     @el.find('#graph').removeClass('is-zooming')
    #     @plotPoints(wMin,wMax)
    #     # @rescaleMarks(wMin,wMax)
    # ), 30

  drawXTickMarks: (xMin, xMax) ->
    # tick/text properties
    tickMinorLength = 5
    tickMajorLength = 10
    tickWidth = 1
    tickColor = '#585858'
    textColor = '#585858'
    textSpacing = 15

    # determine intervals
    xMag = Math.round( Math.abs(xMin-xMax) )
    if xMag <= 2 # days
      majorTickInterval = 4
      minorTickInterval = 16
      textInterval = 8
    else if xMag <= 10 # days
      majorTickInterval = 4
      minorTickInterval = 4
      textInterval = 4
    else # all days
      majorTickInterval = 2
      minorTickInterval = 1
      textInterval = 2

    # generate intervals
    xTicks = []
    xStep = 1/minorTickInterval
    i = 0
    xVal = Math.floor(xMin)
    while xVal <= Math.ceil(xMax)
      for j in [0...minorTickInterval]
        tick = xVal + j*xStep;
        unless tick > Math.ceil(xMax)
          xTicks.push tick
      i++
      xVal++

    for tick, i in [xTicks...]
      continue if i is 0 # skip first value

      # draw ticks (bottom)
      @ctx.beginPath()
      @ctx.moveTo( @toPixels(tick)+@leftPadding, @canvas.height )
      if i % majorTickInterval is 0
        @ctx.lineTo( @toPixels(tick)+@leftPadding, @canvas.height - tickMajorLength ) # major tick
      else
        @ctx.lineTo( @toPixels(tick)+@leftPadding, @canvas.height - tickMinorLength ) # minor tick
      @ctx.lineWidth = tickWidth
      @ctx.strokeStyle = tickColor
      @ctx.stroke()

      @ctx.font = '10pt Arial'
      @ctx.textAlign = 'center'
      @ctx.fillStyle = textColor

      # draw numbers (bottom)
      if (i % majorTickInterval) is 0 # zoomed out
        @ctx.fillText( tick, @toPixels(tick)+@leftPadding, @canvas.height - textSpacing )
      else if (i % majorTickInterval) is 0
        @ctx.fillText( tick, @toPixels(tick)+@leftPadding, @canvas.height - textSpacing )
      else if (i % majorTickInterval) is 0
        @ctx.fillText( tick, @toPixels(tick)+@leftPadding, @canvas.height - textSpacing )

      # axis header
      @ctx.fillText( 'DAYS', textSpacing+10+@leftPadding, @canvas.height - textSpacing )

      # draw ticks (top)
      @ctx.beginPath()
      @ctx.moveTo( @toPixels(tick)+@leftPadding, 0 )
      if i % majorTickInterval is 0
        @ctx.lineTo( @toPixels(tick)+@leftPadding, 0 + tickMajorLength ) # major tick
      else
        @ctx.lineTo( @toPixels(tick)+@leftPadding, 0 + tickMinorLength ) # minor tick
      @ctx.lineWidth = tickWidth
      @ctx.strokeStyle = tickColor
      @ctx.stroke()

      # top numbers
      if (i % 4) is 0 # zoomed out
        @ctx.fillText( (tick + @originalMin).toFixed(2), @toPixels(tick)+@leftPadding, 0 + textSpacing+10 )

  drawYTickMarks: (yMin, yMax) ->
    # generate intervals
    yTicks = []
    yStep = Math.abs(yMin-yMax)/20
    meanTickIndexIsEven = false
    tickIdx = 0

    numStepsUp = Math.ceil (yMax-1.0)/yStep
    numStepsDown = Math.round (1.0-yMin)/yStep

    for stepFactor in [-numStepsDown..numStepsUp]
      tickValue = 1+stepFactor*yStep
      unless tickValue >= yMax or tickValue <=yMin
        if tickValue is 1.0
          if (tickIdx%2 is 0)
            meanTickIndexIsEven = true
        yTicks.push tickValue
        tickIdx++

    if yStep < 0.001
      textDecimals = 4
    else
      textDecimals = 3

    tickMinorLength = 5
    tickMajorLength = 10
    tickWidth = 1
    tickColor = '#585858' #'rgba(200,20,20,1)'
    textColor = '#585858'
    textSpacing = 15
    majorTickInterval = 2
    minorTickInterval = 1
    textInterval = 2

    # REQUIRED FOR MEAN NORMALIZATION
    yMean = @mean(@data.y)

    for tick, i in [yTicks...]
      continue if i is 0               # skip first value
      continue if i is yTicks.length-1 # skip last value

      tickPos = @toCanvasYCoord(tick)     # transform to canvas coordinate
      tickPos = -tickPos + @canvas.height # flip y-axis

      # draw axis
      @ctx.font = '10pt Arial'
      @ctx.textAlign = 'left'
      @ctx.fillStyle = textColor
      @ctx.beginPath()
      @ctx.moveTo( 0, tickPos )

      # make sure 1.00 (mean) tickmark is labeled
      if meanTickIndexIsEven
        if i % majorTickInterval is 0
          @ctx.lineTo( tickMajorLength, tickPos ) # major tick
          @ctx.fillText( tick.toFixed(textDecimals), 0+textSpacing, tickPos+5 )

        else
          @ctx.lineTo( tickMinorLength, tickPos ) # minor tick
      else
        if i % majorTickInterval-1 is 0
          @ctx.lineTo( tickMajorLength, tickPos ) # major tick
          @ctx.fillText( tick.toFixed(textDecimals), 0+textSpacing, tickPos+5 )

        else
          @ctx.lineTo( tickMinorLength, tickPos ) # minor tick

      @ctx.lineWidth = tickWidth
      @ctx.strokeStyle = tickColor
      @ctx.stroke()

  clearCanvas: -> @ctx.clearRect(0,0,@canvas.width, @canvas.height)

  toPixels: (dataPoint, printValue) ->
    pixel = ( (parseFloat(dataPoint) - parseFloat(@xMin)) / (parseFloat(@xMax) - parseFloat(@xMin)) ) * \
      ( parseFloat(@canvas.width) - parseFloat(@leftPadding) )
    if printValue
      console.log "[xMin,xMax]  = [#{@xMin},#{@xMax}]"
      console.log "canvas.width = #{@canvas.width}"
      console.log "leftPadding  = #{@leftPadding}"
      console.log "dataPoint    = #{dataPoint}"
      console.log "pixel        = #{pixel}"
    return pixel

  toCanvasYCoord: (dataPoint) -> ((parseFloat(dataPoint) - parseFloat(@yMin)) / (parseFloat(@yMax) - parseFloat(@yMin))) * (parseFloat(@canvas.height))
  toDays: (canvasPoint) -> ((parseFloat(canvasPoint) / (parseFloat(@canvas.width)-parseFloat(@leftPadding))) * (parseFloat(@xMax) - parseFloat(@xMin))) + parseFloat(@xMin)
  toDataYCoord: (canvasPoint) -> ((parseFloat(canvasPoint) / parseFloat(@canvas.height)) * (parseFloat(@yMax) - parseFloat(@yMin))) + parseFloat(@yMin)

  addMarkToGraph: (e) =>
    return if @markingDisabled
    e.preventDefault()
    if @marks.markTooCloseToAnother(e, @scale, @originalMin)
      @notify 'Marks may not overlap!'
      @shakeGraph()
      return

    # create new mark
    @mark = new Mark(e, @, @originalMin)
    # return unless @mark.containsPoints()
    @marks.appendElement(@mark)
    @mark.draw(e)
    @mark.onMouseDown(e)

  shakeGraph: ->
    graph = $('#graph-container')
    return if graph.hasClass('shaking')
    graph.addClass('shaking')
    graph.effect( "shake", {times:4, distance: 2}, 700, =>
        graph.removeClass('shaking')
      ) # eventually remove jquery ui dependency?

class Marks
  constructor: -> @all = []
  appendElement: (mark) -> document.getElementById('marks-container').appendChild(mark.element)
  add: (mark) -> @all.push(mark)

  remove: (mark) ->
    @all.splice(@all.indexOf(mark), 1)
    document.getElementById('marks-container').removeChild(mark.element)

  destroyAll: ->
    mark.element.outerHTML = "" for mark in @all
    @all = []
    document.getElementById('marks-container')

  sortedXCoords: ->
    allXPoints = ([mark.canvasXMin, mark.canvasXMax] for mark in @all)
    [].concat.apply([], allXPoints).sort (a, b) -> a - b
    # or
    # (allXPoints.reduce (a, b) -> a.concat b).sort (a, b) -> a - b

  closestXBelow: (xCoord) -> (@sortedXCoords().filter (i) -> i < xCoord).pop()
  closestXAbove: (xCoord) -> (@sortedXCoords().filter (i) -> i > xCoord).shift()
  toCanvasXPoint: (e) -> e.pageX - e.target.getBoundingClientRect().left - window.scrollX 

  markTooCloseToAnother: (e, scale) ->
    mouseLocation = @toCanvasXPoint(e)
    markBelow = Math.abs mouseLocation - @closestXBelow(mouseLocation)
    markAbove = Math.abs mouseLocation - @closestXAbove(mouseLocation)
    # 22 is width of mark plus some room on each side
    markBelow < (scale) or markAbove < (scale) or mouseLocation in @sortedXCoords()

module?.exports = CanvasGraph