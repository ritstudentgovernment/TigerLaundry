#= require d3

# HOW TO GET A GRAPH:
# 
# Make a div and place the .facility-graph class on it.
# If axes are desired, also place the .draw-xaxis or .draw-yaxis classes
# Default graph is an average-area graph (averages washers + driers)
# To get a line graph, include the class .facility-graph-line
# To get a stacked area graph, include the class .facility-graph-stacked-area

# An abstract class defining a Graph
# Instance variables:
#   @elem   -> the DOM element
#   @$_elem -> the jQuery element
#   @facility_id -> the id of this facility
#   @height -> the height (of the viewBox), int
#   @width  -> the width (of the viewBox), int
#   @margin -> object with the margin values
#   @x      -> the x-axis scaling function (pass it data, it gives you pixels)
#   @y      -> the y-axis scaling function
#   @svg    -> a reference to the d3
#   @xAxis  -> the object that draws the x-axis
#   @yAxis  -> the object that draws the y-axis
class Graph

  # Construct this Graph and associate this
  # pure-javascript DOM element with it
  # params:
  #   elem - a pure DOM element
  constructor: (elem) ->
    @elem = elem
    @$_elem = $(elem)
    @facility_id = @$_elem.attr("facility-id")
    @setDims()
    @setupResizing()
    @setData()
    @setAxes()
    @setSVG()

  # sets the @width and @height variables
  setDims: () ->
    @setMargin()
    @setHeightWidth()

  # sets the @margin variable, accounting for axes
  setMargin: () ->
    @margin = {
      top:    if @shouldDrawYAxis() then 20 else 5
      right:  5
      bottom: if @shouldDrawXAxis() then 30 else 5
      left:   if @shouldDrawYAxis() then 70 else 5
    }

  setHeightWidth: () ->
    @width  = 500
    @height = Math.floor(@width*(9/16)) # sets a 16:9 ViewBox ratio

  setAxes: () ->
    @setXAxis()
    @setYAxis()

  setXAxis: () ->
    @x = d3.time.scale().range [0, @width]
    @xAxis = d3.svg.axis()
               .scale(@x)
               .orient("bottom")
               .ticks(d3.time.hours, 1) # make a tick mark every hour
               .tickFormat(d3.time.format("%I%p")) # make a tick look like 09PM
    @x.domain(d3.extent(@data, (d) -> d.date))

  setYAxis: () ->
    @y = d3.scale.linear().range([@height, 0])
    @yAxis = d3.svg.axis()
               .scale(@y)
               .orient("left")
               .tickValues([0, 20, 40, 60, 80, 100]) # put ticks every 20%
               .tickFormat((d) -> d + "%") # make the ticks look like percents
    @y.domain [0, 100]

  # set up a callback so the @elem (wrapping the svg) will have a
  # limited height. fixes chrome being greedy about height
  setupResizing: () ->
    elem = @$_elem
    height = @height
    width  = @width
    setHeight = () ->
      elem.css "height", Math.floor($(elem).width()*(height/width))
      console.log "Foo!"
    setHeight()
    $(window).resize setHeight

  # Set the submission data, @data to an array of objects:
  # [ {date: date, washers: int, driers: int},  ... ]
  setData: () ->
    data = []
    path = "/facilities/#{@facility_id}/submissions/limited.json"
    parseDate = d3.time.format("%Y-%m-%d %H:%M:%S UTC").parse

    $.ajax(path, {async: false, accepts: "application/json"})
    .done( (json_data) ->
      # sanity check to make sure data is parsed
      if json_data instanceof String
        json_data = JSON.parse json_data
      for datum in json_data
        data.push({
          date:    parseDate String(datum[0])
          washers: datum[1]
          driers:  datum[2]
        })
    )
    @data = data

  # set the @svg object with the appropriate viewbox, and
  # make it scale to fill the size of the container
  setSVG: () ->
    width = @width + @margin.left + @margin.right
    height = @height + @margin.top + @margin.bottom
    @svg = d3.select(@elem).append("svg")
        .attr("viewBox", "0 0 #{width} #{height}")
        .attr("width", "100%")
        .attr("height","100%")
      .append("g")
        .attr("transform", "translate(#{@margin.left}, #{@margin.top})")

  shouldDrawXAxis: () ->
    @$_elem.hasClass "draw-xaxis"

  shouldDrawYAxis: () ->
    @$_elem.hasClass "draw-yaxis"

  # Draw the graph!
  graph: () ->
    @drawFigures()
    @drawAxes()

  # IMPLEMENT THIS IN SUBCLASSES!
  drawFigures: () ->
    null

  drawAxes: () ->
    if @shouldDrawXAxis()
      @svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0,"+ @height + ")")
        .call(@xAxis)
    if @shouldDrawYAxis()
      @svg.append("g")
          .attr("class", "y axis")
          .call(@yAxis)
        .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", -50)
          .attr("x", -80)
          .style("text-anchor", "end")
          .style("font-size", "12pt")
          .text("Percent In Use")

# ########### Concrete implementations of Graphs ############### #

class AverageAreaGraph extends Graph
  
  drawFigures: () ->
    x = @x
    y = @y
    avgArea = d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( @height )
        .y1( (d) -> y((d.washers + d.driers)/2))
        .interpolate("monotone")
    @svg.append("path")
      .datum(@data)
       .attr("class", "area area-average")
       .attr("d", avgArea)

class LineGraph extends Graph

  drawFigures: () ->
    x = @x
    y = @y
    washersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.washers) )
        .interpolate("monotone")
    driersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.driers) )
        .interpolate("monotone")
    @svg.append("path")
      .datum(@data)
      .attr("class", "line line-washers")
      .attr("d", washersLine)
    @svg.append("path")
      .datum(@data)
      .attr("class", "line line-driers")
      .attr("d", driersLine)

class StackedAreaGraph extends Graph

  drawFigures: () ->
    x = @x
    y = @y
    washersArea = d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( @height )
        .y1( (d) -> y(d.washers/2) )
        .interpolate("monotone")
    driersArea = d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( (d) -> y(d.washers/2) )
        .y1( (d) -> y((d.washers + d.driers)/2) )
        .interpolate("monotone")
    washersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.washers/2) )
        .interpolate("monotone")
    driersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y((d.driers + d.washers)/2) )
        .interpolate("monotone")
    @svg.append("path")
      .datum(@data)
      .attr("class", "area area-washers")
      .attr("d", washersArea)
    @svg.append("path")
      .datum(@data)
      .attr("class", "area area-driers")
      .attr("d", driersArea)
    @svg.append("path")
      .datum(@data)
      .attr("class", "line line-washers")
      .attr("d", washersLine)
    @svg.append("path")
      .datum(@data)
      .attr("class", "line line-driers")
      .attr("d", driersLine)

drawAllGraphs = () ->
  for graph in $(".facility-graph")
    $_graph = $(graph)
    if $_graph.hasClass("facility-graph-stacked-area")
      g = new StackedAreaGraph(graph)
    else if $_graph.hasClass("facility-graph-line")
      g = new LineGraph(graph)
    else
      g = new AverageAreaGraph(graph)
    g.graph()

  # With turbolinks enabled, both of these have to be here
  # to ensure that drawAllGraphs is fired on page changes
document.addEventListener("page:load", drawAllGraphs)
$(document).ready(drawAllGraphs)
