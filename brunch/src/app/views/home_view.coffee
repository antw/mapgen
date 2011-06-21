homeTemplate = require 'templates/home'

class exports.HomeView extends Backbone.View
  id: 'home-view'

  events:
    'mousemove #original canvas': 'moveOriginal'
    'mousemove #lloyd canvas':    'moveLloyd'

    'mouseenter #original':       'showCrosshair'
    'mouseout   #original':       'hideCrosshair'

    'mouseenter #lloyd':          'showCrosshair'
    'mouseout   #lloyd':          'hideCrosshair'

  constructor: ->
    super()
    _.bindAll this, 'moveOriginal', 'moveLloyd',
                    'showCrosshair', 'hideCrosshair'

  render: ->
    $(@.el).html homeTemplate()

    @original  = @$ '#original'
    @lloyd     = @$ '#lloyd'
    @crosshair = @$ '#crosshair'
    @diff      = @$ '#diff'

    ctx = @crosshair[0].getContext('2d')

    ctx.strokeStyle = '#000'
    ctx.lineWidth = 0.5
    ctx.beginPath()

    ctx.moveTo(10.5,  0)
    ctx.lineTo(10.5, 10)
    ctx.moveTo(10.5, 11)
    ctx.lineTo(10.5, 21)

    ctx.moveTo(0,  10.5)
    ctx.lineTo(10, 10.5)
    ctx.moveTo(11, 10.5)
    ctx.lineTo(21, 10.5)
    ctx.stroke()

    ctx.fillStyle   = 'rgba(0, 0, 0, 0.15)'
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.4)'

    # ctx.moveTo(5, 5)
    ctx.arc(10.5, 10.5, 5, 0, Math.PI * 2, true)
    ctx.fill()
    ctx.stroke()

    @

  moveCrosshair: (x, y) ->
    @crosshair.css left: x - 9, top: y - 9

  moveOriginal: (event) ->
    oOffset = @original.offset()
    lOffset = @lloyd.offset()

    x = event.pageX - oOffset.left
    y = event.pageY - oOffset.top

    @moveCrosshair lOffset.left + x, lOffset.top + y

  moveLloyd: (event) ->
    oOffset = @original.offset()
    lOffset = @lloyd.offset()

    x = event.pageX - lOffset.left
    y = event.pageY - lOffset.top

    @moveCrosshair oOffset.left + x, oOffset.top + y

  showCrosshair: (event) ->
    @crosshair.show()
    @diff.show()

    if $(event.currentTarget).attr('id') is 'original'
      offset = @original.offset()
    else
      offset = @lloyd.offset()

    @diff.show().css
      left: offset.left
      top:  offset.top

  hideCrosshair: ->
    @crosshair.hide()
    @diff.hide()
