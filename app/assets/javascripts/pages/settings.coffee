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
    $.randomKey = randomString()
    while jQuery.inArray($.randomKey, gon.keys) >= 0
      $.randomKey = randomString()
    $('.app_key').html $.randomKey
    $.ajax
      data: {website: {id: $.website_id, app_key: $.randomKey}}
      url: Routes.api_v1_website_url($.website_id)
      type: 'PUT'
      success: (result)->
        window.location = "/settings"
        alert 'Key updated'
    return

randomString = () ->
  chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz'
  newKey = ''
  i = 0
  string_length = 24
  while i < string_length
    value = Math.floor(Math.random() * chars.length)
    newKey += chars.substring(value, value + 1)
    i++
  return newKey
