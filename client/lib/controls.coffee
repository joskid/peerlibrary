# To close dropdowns when clicking, focusing, or pressing a key somewhere outside
$(document).on 'click focus keypress dragstart', (event) ->
  closestTrigger = $(event.target).closest('.dropdown-trigger').get(0)

  # We only operate on dropdowns in the main section, since we don't want to affect
  # the one in the header. That one is hidden through templates instead of javascript.
  $('section .dropdown-anchor:visible').each (index, element) ->
    $element = $(element)

    # Don't react when trying to open the dropdown
    return if $element.closest('.dropdown-trigger').get(0) is closestTrigger

    $element.hide().trigger('dropdown-hidden')

  return # Make sure CoffeeScript does not return anything

# Close all dropdowns with escape key
$(document).on 'keyup', (event) ->
  if event.keyCode is 27
    # We only operate on dropdowns in the main section, since we don't want to affect
    # the one in the header. That one is hidden through templates instead of javascript.
    $('section .dropdown-anchor:visible').hide().trigger('dropdown-hidden')

  return # Make sure CoffeeScript does not return anything

Meteor.startup ->
  $(document).tooltip
    items: '.tooltip'
    position:
      my: 'center bottom'
      at: 'center top-10'
    show: 200
    hide: 200
