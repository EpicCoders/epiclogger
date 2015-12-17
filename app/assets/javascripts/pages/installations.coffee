PubSub.subscribe('assigned.website', (ev, website)->

  range = $('.input-range')
  value = $('.range-value')
  value.html range.attr('value')
  value.html 'disabled' if range.attr('value') == '0'
  range.on 'input', ->
    value.html @value
    return

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
    else if target.attr('name') == 'integrations'
      $('#client-integrations').show()
      $('#client-details, #client-configuration').hide()
    else if target.attr('name') == 'client configuration'
      $('#client-configuration, #client-information, #client-platforms, #client-frameworks').show()
      $('#client-details, #client-integrations').hide()
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
      $('#client-information, #client-platforms, #client-frameworks').show()

      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data
        $('#current-site').render data
        apiKeyTab(data)



hideListedTabs = () ->
  $('#details-settings,
    #client-details,
    #client-integrations,
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