#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require jquery-ui
# require bootstrap-transition
# require bootstrap-affix
#= require bootstrap-alert
#= require bootstrap-button
# require bootstrap-carousel
# require bootstrap-collapse
#= require bootstrap-dropdown
# require bootstrap-modal
# require bootstrap-scrollspy
# require bootstrap-tab
#= require bootstrap-tooltip
# require bootstrap-popover
#= require bootstrap-typeahead
#= require jquery_nested_form
#= require jquery-ui-datepicker-i18n
#= require_self
#

# scope for global functions
window.Application ||= {}

# add trim function for older browsers
if !String.prototype.trim
  String.prototype.trim = () -> this.replace(/^\s+|\s+$/g, '')


replaceContent = (e, data, status, xhr) ->
  replace = $(this).data('replace')
  el = if replace is true then $(this).closest('form') else $("##{replace}")
  console.warn "found no element to replace" if el.size() is 0
  el.html(data)

setDataType = (xhr) ->
  $(this).data('type', 'html')

# start selection on previously selected date
datepicker = do ->
  lastDate = null
  track = -> lastDate = $(this).val()

  show: ->
    field = $(this)
    console.log(field)
    if field.is('.icon-calendar')
      field = field.parent().siblings('.date')
    field.datepicker(onSelect: track)
    field.datepicker('show')

    if lastDate && field.val() is ""
      field.datepicker('setDate', lastDate)
      field.val('') # user must confirm selection

setupEntityTypeahead = (index, field) ->
  input = $(this)
  setupRemoteTypeahead(input, 10, setEntityId)
  input.keydown((event) ->
    if isModifyingKey(event.which)
      $('#' + input.data('id-field')).val(null).change())

setEntityId = (item) ->
  typeahead = this
  item = JSON.parse(item)
  idField = $('#' + typeahead.$element.data('id-field'))
  idField.val(item.id).change()
  $('<div/>').html(item.label).text()

setupQuicksearch = ->
  qs = $('#quicksearch')
  setupRemoteTypeahead(qs, 20, openQuicksearchResult)

openQuicksearchResult = (item) ->
  typeahead = this
  item = JSON.parse(item)
  url = typeahead.$element.data(item.type + "-url")
  if url
    window.location =  url + '/' + item.id
    label = $('<div/>').html(item.label).text()
    label + " wird geöffnet..."

setupRemoteTypeahead = (input, items, updater) ->
  input.attr('autocomplete', "off")
  input.typeahead(
         source: queryForTypeahead,
         updater: updater,
         matcher: (item) -> true, # match every value returned from server
         sorter: (items) -> items, # keep order from server
         items: items,
         highlighter: typeaheadHighlighter)

queryForTypeahead = (query, process) ->
  return [] if query.length < 3
  $.get(this.$element.data('url'), { q: query }, (data) ->
    json = $.map(data, (item) -> JSON.stringify(item))
    return process(json)
  )

typeaheadHighlighter = (item) ->
  query = this.query.trim().replace(/[\-\[\]{}()*+?.,\\\^$|#]/g, '\\$&')
  query = query.replace(/\s+/g, '|')
  JSON.parse(item).label.replace(new RegExp('(' + query + ')', 'ig'), ($1, match) -> '<strong>' + match + '</strong>')

isModifyingKey = (k) ->
  ! (k == 20 || # Caps lock */
     k == 16 || # Shift */
     k == 9  || # Tab */
     k == 13 || # Enter
     k == 27 || # Escape Key
     k == 17 || # Control Key
     k == 91 || # Windows Command Key
     k == 19 || # Pause Break
     k == 18 || # Alt Key
     k == 93 || # Right Click Point Key
     ( k >= 35 && k <= 40 ) || # Home, End, Arrow Keys
     k == 45 || # Insert Key
     (k >= 33 && k <= 34 )  || # Page Down, Page Up
     (k >= 112 && k <= 123) || # F1 - F12
     (k >= 144 && k <= 145 ))  # Num Lock, Scroll Lock


Application.moveElementToBottom = (elementId, targetId, callback) ->
  $target = $('#' + targetId)
  left = $target.offset().left
  top = $target.offset().top + $target.height()
  $element = $('#' + elementId)
  leftOld = $element.offset().left
  topOld = $element.offset().top
  $element.children().each((i, c) -> $c = $(c); $c.css('width', $c.width()))
  $element.css('left', leftOld)
  $element.css('top', topOld)
  $element.css('position', 'absolute')
  $element.animate({left: left, top: top}, 300, callback)


$ ->
  # wire up quick search
  setupQuicksearch()

  # wire up date picker
  $('body').on('click', 'input.date, .controls .icon-calendar', datepicker.show)

  # wire up elements with ajax replace
  $('body').on('ajax:success','[data-replace]', replaceContent)
  $('body').on('ajax:before','[data-replace]', setDataType)

  # wire up disabled links
  $('body').on('click', 'a.disabled', (event) -> $.rails.stopEverything(event); event.preventDefault();)

  # wire up person auto complete
  $('[data-provide=entity]').each(setupEntityTypeahead)
  $('[data-provide]').each(() -> $(this).attr('autocomplete', "off"))

  # wire up tooltips
  $('body').tooltip({ selector: '[rel=tooltip]', placement: 'right' })

  # set insertFields function for nested-form gem
  window.nestedFormEvents.insertFields = (content, assoc, link) ->
    $(link).closest('form').find("##{assoc}_fields").append($(content))

  # show alert if ajax requests fail
  $(document).on('ajax:error', (event, xhr, status, error) ->
    alert('Sorry, something went wrong\n(' + error + ')'))

  # make clicking on typeahead item always select it (https://github.com/twitter/bootstrap/issues/4018)
  $('body').on('mousedown', 'ul.typeahead', (e) -> e.preventDefault())

  # controll visibilty of group contact fields in relation to contact
  $('#group_contact_id').on('change', do ->
    open = !$('#group_contact_id').val()
    ->
      state = !$(this).val()
      $('fieldset.info').slideToggle() if open != state
      open = state
  )
