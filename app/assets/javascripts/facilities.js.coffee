# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require d3


# ########### HELPER FUNCTIONS FOR GRAPHING ############### #

getMargins = () ->
  return {
    top:    10
    left:   40
    bottom: 30
    right:  20
  }

getWidth  = () -> 500
getHeight = () -> Math.floor(getWidth()*(9/16))

shouldDrawXAxis = (elem) ->
  $(elem).hasClass("draw-xaxis")
shouldDrawYAxis = (elem) ->
  $(elem).hasClass("draw-yaxis")

# Get the submission data for the given facility_id
# returns an array of objects:
# [ {date: date, washers: int, driers: int},  ... ]
getData   = (facility_id) ->
  ret = []
  path = "/facilities/" + facility_id + "/submissions/limited.json"
  parseDate = d3.time.format("%Y-%m-%d %H:%M:%S UTC").parse

  $.ajax(path, {
    async: false
    accepts: "application/json"
  }).done( (data) ->
    # sanity check to make sure data is parsed
    if (data instanceof String)
      data = JSON.parse(data)
    for datum in data
      ret.push({
        date:    parseDate(String(datum[0]))
        washers: datum[1]
        driers:  datum[2]
      })
  )
  ret

# Get an SVG object with the dimensions given
getSVG = (elem, width, height, margin) ->
  width = width + margin.left + margin.right
  height = height + margin.top + margin.bottom
  d3.select(elem).append("svg")
      .attr("viewBox", "0 0 " + width + " " + height)
      .attr("width", "100%")
      .attr("height","100%")
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

# Draw a generic graph
# params:
#   elem: the element container to draw in
#         if elem has a class draw-xaxis and/or draw-yaxis, it will draw the respective axes
#   figures: An array of objects, each object having attributes
#     class: "<html class>"
#     getFig: (x, y, width, height) -> figure
drawGraph = (elem, figures) ->
  $_elem = $(elem)
  $_elem.empty()
  drawXAxis = shouldDrawXAxis($_elem)
  drawYAxis = shouldDrawYAxis($_elem)

  facility_id = parseInt($_elem.attr("facility-id"))
  data = getData(facility_id)
  # dimensions for the graph
  margin = getMargins()
  width  = getWidth()
  height = getHeight()

  # set the element's height to avoid Chrome getting greedy w/ it
  setHeight = () ->
    $_elem.css "height", Math.floor( $_elem.width()*(height/width) )
  setHeight()
  $(window).resize(setHeight)

  x = d3.time.scale().range([0, width])
  y = d3.scale.linear().range([height, 0])
  xAxis = d3.svg.axis().scale(x).orient("bottom").ticks(d3.time.hours, 1).tickFormat(d3.time.format("%I%p"))
  yAxis = d3.svg.axis().scale(y).orient("left").tickValues([0, 20, 40, 60, 80, 100]).tickFormat((d) -> d + "%")

  svg = getSVG(elem, width, height, margin)

  x.domain(d3.extent(data, (d) -> d.date))
  y.domain([0, 100])

  # draw the figures
  for fig in figures
    svg.append("path")
      .datum(data)
      .attr("class", fig.class)
      .attr("d", fig.getFig(x, y, width, height))
  
  # draw the axes
  if drawXAxis
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,"+ height + ")")
      .call(xAxis)
  if drawYAxis
    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)

# ######### GRAPHING FUNCTIONS ######### #

# Draw an area graph of average values (graph of average washer/dryer)
drawAverageArea = (elem) ->
  figures = []
  figures.push({
    class: "area area-average"
    getFig: (x, y, width, height) ->
      d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( height )
        .y1( (d) -> y((d.washers + d.driers)/2))
        .interpolate("monotone")
  })
  drawGraph(elem, figures)


# Draw a strict line graph
drawLine = (elem) ->
  figures = []
  figures.push({
    class: "line line-washers"
    getFig: (x, y, width, height) ->
      d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.washers) )
        .interpolate("monotone")
  })
  figures.push({
    class: "line line-driers"
    getFig: (x, y, width, height) ->
      d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.driers) )
        .interpolate("monotone")
  })
  drawGraph(elem, figures)

# Draw a stacked graph
drawStackedArea = (elem) ->
  figures = []
  # add the washers line
  figures.push({
    class: "line line-washers"
    getFig: (x, y, width, height) ->
      d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.washers/2) )
        .interpolate("monotone")
  })
  # add the washers area
  figures.push({
    class: "area area-washers"
    getFig: (x, y, width, height) ->
      d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( height )
        .y1( (d) -> y(d.washers/2) )
        .interpolate("monotone")
  })

  # add the driers line
  figures.push({
    class: "line line-driers"
    getFig: (x, y, width, height) ->
      d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y((d.driers + d.washers)/2) )
        .interpolate("monotone")
  })
  # add the driers area
  figures.push({
    class: "area area-driers"
    getFig: (x, y, width, height) ->
      d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( (d) -> y(d.washers/2) )
        .y1( (d) -> y((d.washers + d.driers)/2) )
        .interpolate("monotone")
  })

  drawGraph(elem, figures)


drawAllGraphs = () ->
  for graph in $(".facility-graph")
    graph = graph
    facility_id = graph.getAttribute("facility-id")
    drawAverageArea(graph)

# With turbolinks enabled, both of these have to be here
# to ensure that drawAllGraphs is fired on page changes
document.addEventListener("page:load", drawAllGraphs)
$(document).ready(drawAllGraphs)
