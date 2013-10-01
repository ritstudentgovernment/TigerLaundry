# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require d3


# ########### HELPER FUNCTIONS FOR GRAPHING ############### #

getMargins = () ->
    return {
        top:    15
        left:    5
        bottom: 20
        right:  10
    }

getWidth  = (elem) -> $(elem).width()
getHeight = (elem) -> Math.floor(getWidth(elem)/3)

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
    d3.select(elem).append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
        .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

# Draw a generic graph
# params:
#   elem: the element container to draw in
#   figures: An array of objects, each object being
#       class: "<html class>"
#       getFig: (x, y, width, height) -> figure
# returns:
#   the svg object, so it can be further manipulated
drawGraph = (elem, figures) ->
    $_elem = $(elem)
    $_elem.empty()
    facility_id = parseInt($_elem.attr("facility-id"))
    data = $_elem.data("data")
    if not data
        data = getData(facility_id)
        $_elem.data({data: data})
    # dimensions for the graph
    margin = getMargins()
    width  = getWidth(elem)
    height = getHeight(elem)

    x = d3.time.scale().range([0, width])
    y = d3.scale.linear().range([height, 0])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    
    svg = getSVG(elem, width, height, margin)
    
    washersLine = d3.svg.line()
        .x( (d) -> x(d.date) )
        .y( (d) -> y(d.washers) )
        .interpolate("monotone")
    washersArea = d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( height )
        .y1( (d) -> y(d.washers) )
        .interpolate("monotone")

    driersLine = d3.svg.line()
        .x( (d) -> x(d.date)  )
        .y( (d) -> y(d.washers + d.driers))
        .interpolate("monotone")
    driersArea = d3.svg.area()
        .x( (d) -> x(d.date) )
        .y0( (d) -> y(d.washers) )
        .y1( (d) -> y(d.washers + d.driers) )
        .interpolate("monotone")


    x.domain(d3.extent(data, (d) -> d.date))
    y.domain([0, 100])

    # draw the figures
    for fig in figures
        svg.append("path")
            .datum(data)
            .attr("class", fig.class)
            .attr("d", fig.getFig(x, y, width, height))
    # Redraw this if the window is resized
    $(window).resize(() -> drawGraph(elem, figures))

# ######### GRAPHING FUNCTIONS ######### #

# Draw an area graph of average values (graph of average washer/dryer)
drawAverageArea = (elem) ->
    figures = []
    figures.push({
        class: "line line-average"
        getFig: (x, y, width, height) ->
            d3.svg.line()
              .x( (d) -> x(d.date) )
              .y( (d) -> y((d.driers + d.washers)/2) )
              .interpolate("monotone")
    })
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
