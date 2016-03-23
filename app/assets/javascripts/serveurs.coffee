# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('.baies').sortable(
    update: (event, ui) ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
  );
  source_connected_list = source_baie = undefined
  $('.servers').sortable(
    # axis: 'y'
    # handle: '.handle'
    connectWith: ".connectedBaies"
    start: (event, ui) ->
      source_connected_list = ui.item.parent()
      source_baie = ui.item.closest('.baie')
    stop: (event, ui) ->
      if source_connected_list
        update_u_scale(source_connected_list)
      update_u_scale(ui.item.parent())
      # Update alerts if above limit max
      if source_baie
        update_warning_messages(source_baie)
      update_warning_messages(ui.item.closest('.baie'))
    update: ->
      # Take in account last change
      count = $(this).find('span.u_scale').length
      $(this).find('span.u_scale').map(->
        $(this).html "#{count}"
        count = count - 1;
      )
      # Get positions in U
      positions = []
      $(this).find('li.serveur').map(->
        if ( $(this).attr("id")!=undefined && $(this).find('span.u_scale')[0]!=undefined )
          positions.push($(this).find('span.u_scale')[0].innerText)
      )
      # Update db data
      $.post($(this).data('update-url'), $(this).sortable('serialize') + '&salle=' +  $(this).data('salle') + '&ilot=' +  $(this).data('ilot') + '&baie=' +  $(this).data('baie') + '&positions=' + positions)
  );
  update_u_scale = (list) ->
    count = list.find('span.u_scale').length
    list.find('span.u_scale').map(->
      $(this).html "#{count}"
      if (count % 2 == 0)
        $(this).removeClass('odd').addClass('even')
      else
        $(this).removeClass('even').addClass('odd')
      count = count - 1;
    )
  update_warning_messages = (baie) ->
    max_u = baie.closest('.baies').data('max-u')
    max_rj45 = baie.closest('.baies').data('max-rj45')
    max_fc = baie.closest('.baies').data('max-fc')
    total_u = total_rj45 = total_fc = 0
    baie.find('.servers li.serveur').each ->
      if $(this).data('u')
        total_u += $(this).data('u')
      if $(this).data('rj45-futur')
        total_rj45 += $(this).data('rj45-futur')
      if $(this).data('fc-futur')
        total_fc += $(this).data('fc-futur')
    baie.find('.panel-footer .warning-messages').html "" # reset warning messages
    baie.find('.panel-footer .label').each ->
      $(this).removeClass('label-danger')
    baie.find('.panel-footer .u').html "Σ U : " + total_u
    baie.find('.panel-footer .rj45').html "Σ RJ45 : " + total_rj45
    baie.find('.panel-footer .fc').html "Σ FC : " + total_fc
    if total_u>max_u || total_rj45>max_rj45 || total_fc>max_fc
      baie.find('.panel').addClass('panel-danger')
      if total_u>max_u
        baie.find('.panel-footer .warning-messages').append "<div style='color:red;'>Somme des U supérieure à "+max_u+" !</div>"
        baie.find('.panel-footer .u').addClass('label-danger');
      if total_rj45>max_rj45
        baie.find('.panel-footer .warning-messages').append "<div style='color:red;'>Somme des RJ45 supérieure à "+max_rj45+" !</div>"
        baie.find('.panel-footer .rj45').addClass('label-danger');
      if total_fc>max_fc
        baie.find('.panel-footer .warning-messages').append "<div style='color:red;'>Somme des FC supérieure à "+max_fc+" !</div>"
        baie.find('.panel-footer .fc').addClass('label-danger');
    else
      baie.find('.panel').removeClass('panel-danger').addClass('panel-default')


  # Nested forms
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').hide()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  # Add connection between ports
  port_overview = (port, destination)->
    field_server_id = "<input type='hidden' name='#{destination}[server_id]' value='#{port.parent().data('server-id')}' />"
    # field_card_id = "<input type='hidden' name='#{destination}[card_id]' value='#{port.parent().data('card-id')}' />"
    field_composant_type = "<input type='hidden' name='#{destination}[composant_type]' value='#{port.parent().data('composant-type')}' />"
    field_composant_id = "<input type='hidden' name='#{destination}[composant_id]' value='#{port.parent().data('composant-id')}' />"
    field_port_position = "<input type='hidden' name='#{destination}[port_position]' value='#{port.data('position')}' />"
    "<p>#{field_server_id}#{field_composant_type}#{field_composant_id}#{field_port_position}<i class='port port#{port.data('type')} label-primary'></i><span style='margin-left: 5px;'>#{port.parent().data('server-name')} : #{port.data('type')} #{port.data('position')}</span></p>"
  $('.server_back').on "click", ".port", ->
    if $('.port_selection').hasClass('in')
      $('.port_selection .to').html port_overview($(this), 'to')
    else
      $('.port_selection').addClass('in');
      $('.port_selection .from').html port_overview($(this), 'from')

  $('.port_selection .cancel_btn').on "click", ->
    $('.port_selection').removeClass('in');

  # Hide or Show connections
  $('#hide_or_show_connections').on "click", ->
    if ($(".connector") && $(".connector").is( ":visible" ))
      $(".connector").hide()
      $('#hide_or_show_connections').html 'Montrer les connexions'
    else
      $(".connector").show()
      $('#hide_or_show_connections').html 'Masquer les connexions'
    event.preventDefault();

  $('.serveur').hover (->
    $(this).addClass 'hover'
  ), ->
    $(this).removeClass 'hover'
