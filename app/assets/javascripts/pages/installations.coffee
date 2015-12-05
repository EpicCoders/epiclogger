PubSub.subscribe('assigned.website', (ev, website)->

  $.getJSON Routes.api_v1_notification_path(gon.notification_id), { member_id: $.auth.user.id }, (data) ->
    $('input[name=daily_reports]').attr('checked', true) if data.daily_reports
    $('input[name=realtime_error]').attr('checked', true) if data.realtime_error
    $('input[name=when_event]').attr('checked', true) if data.when_event
    $('input[name=more_than_10]').attr('checked',true) if data.more_than_10
    $('#save').prop('disabled', true)

    $('input').change ->
      $('#save').prop('disabled', false)

    $('#save').on 'click', (e) ->
      e.preventDefault()
      $.ajax
        url: Routes.api_v1_notification_path(gon.notification_id)
        type: 'put'
        dataType: 'json'
        data: {
          notification: {
            daily_reports: $('input[name=daily_reports]').is(':checked'),
            realtime_error: $('input[name=realtime_error]').is(':checked'),
            when_event: $('input[name=when_event]').is(':checked'),
            more_than_10: $('input[name=more_than_10]').is(':checked')
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
  $('#configuration-tabs').on 'click', (e) ->
    target = $(e.target.closest("li"))
    e.preventDefault()
    $('#configuration-tabs li').removeClass('active')

    if target.attr('name') == 'details'
      $('#details-settings, #client-details').show()
      $('#client-configuration').hide()
    else if target.attr('name') == 'integrations'
      $('#client-details, #client-configuration').hide()
    else if target.attr('name') == 'client configuration'
      $('#client-configuration, #client-information, #client-platforms, #client-frameworks').show()
      $('#client-details').hide()
    target.addClass('active')

  $('#platforms-tabs, #details-tabs').on 'click', (e) ->
    target = $(e.target.closest("li"))
    $('#platforms-tabs li').removeClass('active')
    $('#details-tabs li').removeClass('active')
    target.addClass('active')
    manipulateInstallationsIndex(target)

  $('#img-platforms').on 'click', (e) ->
    manipulateInstallationsIndex($(e.target).parent())
    $('#platforms-tabs li').removeClass('active')

PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      hideListedTabs()
      switchIndexTabs()
      $('#client-details').hide()
      $('#integrations-details').hide()
      $('#client-information, #client-platforms, #client-frameworks').show()

      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data
        $('#current-site').render data
        apiKeyTab(data)



hideListedTabs = () ->
  $('#details-settings,
    #details-notifications,
    #current-site, #details-rate-limits,
    #details-tags, #details-api-keys,
    #client-information,
    #client-platforms,
    #client-frameworks,
    #javascript,
    #php,
    #python,
    #ruby,
    #java,
    #node-js,
    #ios'
  ).hide()

manipulateInstallationsIndex = (target) ->
  hideListedTabs()
  if target.attr('name') == 'javascript'
    $('#current-site').show()
    $('#javascript').show()
  else if target.attr('name') == 'python'
    $('#current-site').show()
    $('#python').show()
  else if target.attr('name') == 'php'
    $('#current-site').show()
    $('#php').show()
  else if target.attr('name') == 'ruby'
    $('#current-site').show()
    $('#ruby').show()
  else if target.attr('name') == 'java'
    $('#current-site').show()
    $('#java').show()
  else if target.attr('name') == 'node.js'
    $('#current-site').show()
    $('#node-js').show()
  else if target.attr('name') == 'ios'
    $('#current-site').show()
    $('#ios').show()
  else if target.attr('name') == 'all platforms'
    $('#current-site').hide()
    $('#client-information, #client-platforms, #client-frameworks').show()

  else if target.attr('name') == 'settings'
    $('#details-settings').show()
  else if target.attr('name') == 'notifications'
    $('#details-notifications').show()
  else if target.attr('name') == 'rate limits'
    $('#details-rate-limits').show()
  else if target.attr('name') == 'tags'
    $('#details-tags').show()
  else if target.attr('name') == 'api keys'
    $('#details-api-keys').show()
)