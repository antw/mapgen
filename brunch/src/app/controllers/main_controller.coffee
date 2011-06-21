{ Map }      = require 'models/map'
{ MapView }  = require 'views/map_view'
{ HomeView } = require 'views/home_view'

{ MAP_DATA } = require 'models/map_data'

class exports.MainController extends Backbone.Controller
  routes :
    "home": "home"

  home: ->
    mapData = MAP_DATA()

    # Render the main home view, before proceeding to sort out the maps.
    $('body').html app.views.home.render().el

    size  = 600
    xmargin = size * 0.04
    ymargin = size * 0.04

    xo = xmargin
    dx = size - xmargin * 2
    yo = ymargin
    dy = size - ymargin * 2

    createPoint = ->
      x: Math.round((xo + Math.random() * dx) * 10) / 10
      y: Math.round((yo + Math.random() * dy) * 10) / 10

    # Create some random sites for the Voronoi diagram.
    # mapData = ( createPoint() for i in [1..300] )

    # f = (n) ->
    #   rounded = Math.round(n)
    #   blanks =  3 - rounded.toString().length
    #   Array(blanks + 1).join(' ') + rounded

    # for site in mapData
    #   console.log "{ x: #{f site.x}, y: #{f site.y} }"#

    # Create the map!
    map = new Map(size, mapData)

    origView = new MapView(map, mapData, size)
    $('#original').html origView.render().el

    map.go()

    newView = new MapView(map, mapData, size)
    $('#lloyd').html newView.render().el

    # Draw how the centroids changed.
    ctx = $('#diff')[0].getContext('2d')
    ctx.beginPath()
    ctx.strokeStyle = '#8bdc94'

    for centroid, i in MAP_DATA()
      ctx.moveTo centroid.x, centroid.y
      ctx.lineTo mapData[i].x, mapData[i].y

    ctx.stroke()
