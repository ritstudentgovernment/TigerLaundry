# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require twitter/bootstrap
#= require bootstrap-slider
#= require modernizr.custom
#= require_tree .


# set up sliders
# sliders that also have a .tl-slider-machinestatus class are formatted special:
#   * accept [0, 100] range
#   * tooltips will show "<n>% full" where n is the slider value
# 
# if the given element has a value-holder attribute, its value is used as a selector,
# and whenever the slider changes it will update the inner html of the selected element
# to match the value represented by the slider
# 
# params:
#   elem - the input element to turn into a slider
setupSlider = (elem) ->
  slider = $(elem)
  oldVal = parseInt(slider.val())
  if not oldVal
    oldVal = 0

  valElem = $(slider.attr("value-holder"))
  updateSlider = (ev) ->
    # for some reason it doesn't handle big jumps well unless
    # setTimeout is used. probably a race condition in the slider
    setTimeout( (() ->
      perc = slider.val()
      valElem.html(perc)
      ), 2)
  slider.on("slide", updateSlider)
  slider.on("slideStop", updateSlider)
  slider.on("slideStart", updateSlider)
  valElem.html(0)

  # if this is a slider for machine status, format it here
  if slider.hasClass("tl-slider-machinestatus")
    slider.slider({
      min: 0,
      max: 100,
      tooltip: "hide",
      value: oldVal
    })
  else
    slider.slider({value: oldVal})

# set .tl-slider class to be sliders
setupSliders = () ->
  for slider in $(".tl-slider")
    setupSlider(slider)

$(document).ready( setupSliders )
document.addEventListener("page:load", setupSliders)
