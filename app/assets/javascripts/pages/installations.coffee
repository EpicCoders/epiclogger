PubSub.subscribe('assigned.website', (ev, website)->

  # $('.input-range').slider
  #   min: 0
  #   max: 168
  #   slide: (event, ui) ->
  #     if ui.value == 0
  #       $('.range-value').text 'disabled'
  #     else if ui.value == 1
  #       $('.range-value').text ui.value + ' hour'
  #     else if ui.value > 12
  #       step: 3
  #     else if ui.value > 1 && ui.value < 25
  #       $('.range-value').text ui.value + ' hours'

  # range = $('.input-range')
  # value = $('.range-value')
  # value.html range.attr('value')
  # value.html 'disabled' if range.attr('value') == '0'
  # range.on 'input', ->
  #   value.html @value
  #   return

  $.getJSON Routes.api_v1_notifications_path(), { website_id: website.id }, (data) ->
    $('input[name=daily]').attr('checked', true) if data.daily
    $('input[name=realtime]').attr('checked', true) if data.realtime
    $('input[name=new_event]').attr('checked', true) if data.new_event
    $('input[name=frequent_event]').attr('checked',true) if data.frequent_event
    $('#save, #add-website').prop('disabled', true)

    $('#title, #domain').change ->
      $('#add-website').prop('disabled', false)

    $('input').change ->
      $('#save').prop('disabled', false)

    $('#save').on 'click', (e) ->
      e.preventDefault()
      $.ajax
        url: Routes.api_v1_notification_path(data.id)
        type: 'put'
        dataType: 'json'
        data: {
          notification: {
            daily: $('input[name=daily]').is(':checked'),
            realtime: $('input[name=realtime]').is(':checked'),
            new_event: $('input[name=new_event]').is(':checked'),
            frequent_event: $('input[name=frequent_event]').is(':checked')
          }
        }
        success: (data) ->
          $('#save').prop('disabled', true)
          swal("Success!", "You will recieve notifications soon.", "success")
)

apiKeyTab = (data) ->
  $.website_id = data.id
  $('#generateAppKey, #revoke').on 'click', (e)->
    e.preventDefault();
    $.ajax
      data: {website: {id: $.website_id, generate: true}}
      url: Routes.api_v1_website_url($.website_id)
      type: 'PUT'
      success: (result)->
        window.location = "/settings"
        swal('Key updated')
    return

switchIndexTabs = () ->
  $('#add-website').on 'click', (e) ->
    e.preventDefault()
    domain_url = $('#formWebsite').find('#domain').val()
    url_title = $('#formWebsite').find('#title').val()
    if (domain_url.replace(/\s+/g, '') || url_title.replace(/\s+/g, '')) == null || (domain_url.replace(/\s+/g, '') || url_title.replace(/\s+/g, '')) == ""
      swal("A valid website is is needed.")
      setTimeout (->
          location.href = '/installations'
          return
        ), 2000
    else
      $.ajax
        url: Routes.api_v1_websites_url()
        type: 'post'
        dataType: 'json'
        data: { role: $('#member-role').val(), website: { domain: domain_url, title: url_title } }
        success: (data) ->
          EpicLogger.setMemberDetails(data.id)
          swal("Good job!", "Website added!", "success")
          $('#add-website').prop('disabled', true)
          setTimeout (->
            location.href = '/installations'
            return
          ), 2000
        error: (error) ->
          sweetAlert("Error", "Website exists", "error") if error.status == 401

  $('#configuration-tabs').on 'click', (e) ->
    target = $(e.target.closest("li"))
    e.preventDefault()
    $('#configuration-tabs li').removeClass('active')

    if target.attr('name') == 'details'
      $('#details-settings, #client-details').show()
      $('#client-configuration, #client-integrations').hide()
      getLastClicked('#details-tabs')
    else if target.attr('name') == 'integrations'
      $('#client-integrations').show()
      $('#client-details, #client-configuration').hide()
    else if target.attr('name') == 'client configuration'
      $('#client-configuration, #client-information, #client-platforms, #client-frameworks').show()
      $('#client-details, #client-integrations').hide()
      getLastClicked('#platforms-tabs')
    target.addClass('active')


  $('#platforms-tabs, #details-tabs').on 'click', (e) ->
    return false if e.target.closest('li') == null
    target = $(e.target.closest("li"))
    target.addClass('active')
    tab = '#'+e.target.parentElement.parentElement.id
    manipulateInstallationsIndex(target, tab)

  $('#img-platforms').on 'click', (e) ->
    position = $.inArray($(e.target).parent()[0], $('#img-platforms a')) + 2
    $('#platforms-tabs li:nth-child('+position+')').addClass('active')
    manipulateInstallationsIndex($(e.target).parent(), "#platforms-tabs", true)

PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      switchIndexTabs()
      $('.tab').hide()
      $('#client-details, #details-notifications').hide()
      $('#client-information, #client-platforms, #client-frameworks').show()

      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data
        $('#current-site').render data
        apiKeyTab(data)

getLastClicked = (id) ->
  removeActiveClass()
  $('.tab').hide()
  if id == '#details-tabs'
    position = $.cookie('detail-tab') || 1
    tabs = ['#details-settings', '#details-notifications', '#details-api-keys']
    $(id + ' li:nth-child('+position+')').addClass('active')
    $(tabs[position-1]).show()
  else
    $('#platforms-tabs li:first').addClass('active')
    $('#client-information, #client-platforms, #client-frameworks').show()


removeActiveClass = () ->
  $('#platforms-tabs li').removeClass('active')
  $('#details-tabs li').removeClass('active')

manipulateInstallationsIndex = (target, tab, img) ->
  removeActiveClass()
  $('.tab').hide()
  position = $.inArray(target[0], $(tab + ' li'))
  target.addClass('active')
  if img != undefined
    $('#current-site').show()
    $('#'+target.attr('name')).show()
  else if position > 0 && tab == '#platforms-tabs'
    $('#current-site').show()
    $('#'+target.attr('name')).show()
  else if tab == '#platforms-tabs' && position == 0
    $('#current-site').hide()
    $('#client-information, #client-platforms, #client-frameworks').show()
  else if tab == '#details-tabs'
    $('#details-'+target.attr('name').replace(/\s+/g, '-').toLowerCase()).show()
    $.cookie('detail-tab', position+1)
)