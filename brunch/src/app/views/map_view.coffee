mapTemplate = require 'templates/map'

class exports.MapView extends Backbone.View
  className: 'map'

  events:
    'mouseover':  'showCoordinates'
    'mouseleave': 'hideCoordinates'
    'mousemove':  'drawCoordinates'

  # Creates a new MapView, which presents the Map given as the argument to
  # the constructor.
  #
  constructor: (@map, @sites, @size) ->

  drawCoordinates: (event) ->
    x = event.pageX - @$('canvas').offset().left
    y = event.pageY - @$('canvas').offset().top

    @$('code').text "#{x}x#{y}"
    @$('code').css
      left: x + 10
      top:  y + 10

  showCoordinates: ->
    @$('code').fadeIn 'fast'

  hideCoordinates: (event) ->
    console.log(event.target)
    @$('code').fadeOut 'fast'

  # Renders the map by drawing the voronoi diagram in the map model.
  #
  render: ->
    $(@.el).html mapTemplate(size: @size)
    canvas = @$('canvas')
    @drawDiagram @map.diagram, canvas

    @

  drawDiagram: (diagram, canvas) ->
    context = canvas[0].getContext '2d'

    # Background.
    context.globalAlpha = 1

    # Sites.
    context.beginPath()
    context.fillStyle = '#f20'

    for site in @sites
      context.moveTo site.x, site.y
      context.arc site.x, site.y, 2, 0, Math.PI * 2, true

    context.fill()

    # Cell lines.
    context.beginPath()
    context.strokeStyle = '#999'

    for edge in @map.diagram.edges
      # Don't draw edges around the canvas boundary.
      vaX = Math.round edge.va.x
      vaY = Math.round edge.va.y
      vbX = Math.round edge.vb.x
      vbY = Math.round edge.vb.y

      unless (vaX <=     0 and vbX <=     0) or
             (vaX >= @size and vbX >= @size) or
             (vaY <=     0 and vbY <=     0) or
             (vaY >= @size and vbY >= @size)
        context.moveTo edge.va.x, edge.va.y
        context.lineTo edge.vb.x, edge.vb.y

    context.stroke()
