PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      createWebsite()
      $('.tab, .main-tabs').hide()
      $('#client-configuration, #platforms-tabs, #all-platforms-tab').show()

      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data
        $('#current-site').render data
        apiKeyTab(data)

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

apiKeyTab = (data) ->
  $.website_id = data.id
  $('#generateAppKey, #revoke').on 'click', (e)->
    e.preventDefault();
    $.ajax
      data: {website: {id: $.website_id, generate: true}}
      url: Routes.api_v1_website_url($.website_id)
      type: 'PUT'
      success: (result)->
        swal('Key updated')
        setTimeout (->
          location.href = '/installations'
          return
        ), 2000
    return

createWebsite = () ->
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


  $('#top-tabs a').on 'click', (e) ->
    e.preventDefault()
    $('.main-tabs').hide()
    $(this).tab('show')
    $($(this).attr('href')).show()
    ul = $($($(this).attr('href') + ' ul')[0])
    ul.show()
    content = $("#" + ul.attr('id') + ' li.active a').attr('href')
    $(content + '-tab').show()
    if content != '#all-platforms' && $(this).attr('href') == "#client-configuration"
      $('#current-site').show()

  $('#platforms-tabs a').click (e) ->
    e.preventDefault()
    toggleTabs( e.target,'platforms' )

  $('#details-tabs a').click (e) ->
    e.preventDefault()
    toggleTabs( e.target,'details' )

  $('#img-platforms a').on 'click', (e) ->
    e.preventDefault()
    $('.tab').hide()
    $('#current-site').show()
    $($(this).attr('href') + '-tab').show()
    $('#platforms-tabs li').removeClass('active')

  toggleTabs = (target,location) ->
    $('.tab').hide()
    $(target).tab('show')
    tag = $(target).attr('href')
    if location == 'platforms'
      if tag != '#all-platforms'
        $('#current-site').show()
    $(tag + '-tab').show()
    return