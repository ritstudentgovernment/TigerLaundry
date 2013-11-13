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
    @width  = @$_elem.parent().width() # the viewbox for the svg (not the actual size of the svg)
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

  setupResizing: () ->
    null

  # Set the submission data, @data to an array of objects:
  # [ {date: date, washers: int, driers: int},  ... ]
  setData: () ->
    hours = 4 # number of hours to go back
    data = []
    path = "/facilities/#{@facility_id}/submissions/limited.json?hours=" + hours
    parse_date = d3.time.format.iso.parse

    $.ajax(path, {async: false, accepts: "application/json"})
    .done( (json_data) ->
      # sanity check to make sure data is parsed
      if json_data instanceof String
        json_data = JSON.parse json_data
      for datum in json_data
        data.push({
          date:    parse_date datum[0]
          washers: datum[1]
          driers:  datum[2]
        })
    )
    # add a fake data point to the biginning and end
    # which are the same size as the ones closer to the middle than them
    # This forces the graph to always be a full {hours} in range
    old = new Date()
    now = new Date()
    old = new Date(old.setHours(now.getHours() - hours))
    # Add the fake point that is {hours} old
    data.unshift({
      date: old
      washers: data[0].washers
      driers:  data[0].driers
    })
    # Add the fake point that is now
    data.push({
      date: now
      washers: data[data.length-1].washers
      driers: data[data.length-1].driers
    })
    @data = data

  # set the @svg object with the appropriate viewbox, and
  # make it scale to fill the size of the container
  setSVG: () ->
    width = @width + @margin.left + @margin.right
    height = @height + @margin.top + @margin.bottom
    @svg = d3.select(@elem).append("svg")
        .attr("viewBox", "0 0 #{width} #{height}")
        .attr("preserveAspectRatio", "xMinYMid")
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
    fontSize = "13pt"
    if @shouldDrawXAxis()
      @svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0,"+ @height + ")")
        .style("font-size", fontSize)
        .call(@xAxis)
    if @shouldDrawYAxis()
      @svg.append("g")
          .attr("class", "y axis")
          .style("font-size", fontSize)
          .call(@yAxis)
        .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", -50)
          .attr("x", -80)
          .style("text-anchor", "end")
          .style("font-size", fontSize)
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
        .interpolate("basis")
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
        .interpolate("basis")
    driersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.driers) )
        .interpolate("basis")
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
        .interpolate("basis")
    driersArea = d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( (d) -> y(d.washers/2) )
        .y1( (d) -> y((d.washers + d.driers)/2) )
        .interpolate("basis")
    washersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.washers/2) )
        .interpolate("basis")
    driersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y((d.driers + d.washers)/2) )
        .interpolate("basis")
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
