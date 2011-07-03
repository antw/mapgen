class exports.Map extends Backbone.Model
  NUM_POINTS           = 300
  NUM_LLOYD_ITERATIONS = 2

  # Creates a new Map instance. The underlying Voronoi instance is available
  # as map.diagram. The Map should be initialized with an array of hashes each
  # containing an x and y value, where each point is used in generating the
  # voronoi diagram.
  #
  constructor: (@size = 800, @points) ->
    super()

    @voronoi = new Voronoi()
    @diagram = @voronoi.compute(points, xl: 0, xr: @size, yt: 0, yb: @size)

    @go()

  # Builds the map.
  #
  go: ->
    # points = @generateRandomPoints()
    @improveRandomPoints(@points)
    @diagram = @voronoi.compute(@points, xl: 0, xr: @size, yt: 0, yb: @size)

  # Creates NUM_POINTS random points which are used when generating the
  # Voronoi diagram.
  #
  # Returns an array of objects with an x and y key.
  #
  generateRandomPoints: ->
    pad = @size - 20

    for i in [ 1..NUM_POINTS ]
      { x: 10 + pad * Math.random(), y: 10 + pad * Math.random() }

  # Improve the random set of points with Lloyd Relaxation.
  #
  # We'd really like to generate "blue noise". Algorithms:
  #
  # 1. Poisson dart throwing: check each new point against all existing
  #    points, and reject it if it's too close.
  #
  # 2. Start with a hexagonal grid and randomly perturb points.
  #
  # 3. Lloyd Relaxation: move each point to the centroid of the generated
  #    Voronoi polygon, then generate Voronoi again.
  #
  # 4. Use force-based layout algorithms to push points away.
  #
  # 5. More at http://www.cs.virginia.edu/~gfx/pubs/antimony/
  #
  # Option 3 is implemented here. If it's run for too many iterations, it will
  # turn into a grid, but convergence is very slow, and we only run it a few
  # times.
  #
  improveRandomPoints: (points) ->
    for i in [ 1..NUM_LLOYD_ITERATIONS ]
      diagram = new Voronoi().compute points,
        xl: 0, xr: @size, yt: 0, yb: @size

      for point, pointIndex in points when diagram.cells[pointIndex]
        region = _.detect diagram.cells, (cell) ->
          cell.site.x is point.x and cell.site.y is point.y

        point.x = 0.0
        point.y = 0.0

        for halfedge in region.halfedges
          point.x += (halfedge.edge.va.x + halfedge.edge.vb.x) / 2
          point.y += (halfedge.edge.va.y + halfedge.edge.vb.y) / 2

        # use seen rather than halfedges since there may have been
        # duplicate vertices
        point.x /= region.halfedges.length
        point.y /= region.halfedges.length
