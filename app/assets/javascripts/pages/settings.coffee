PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data
        manipulateSettingsData(data)
)

manipulateSettingsData = (data) ->
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
