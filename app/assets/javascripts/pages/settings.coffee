directive = {
  app_id:
    html: ()->
      "<h5>App Id: #{this.app_id}<h5>"
  errors:
    html: ()->
      "<h5>Errors: #{this.errors}</h5>"
  subscribers:
    html: ()->
      "<h5>Subscribers: #{this.subscribers}</h5>"
  members:
    html: ()->
      "<h5>Members: #{this.members}</h5>"
}
PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data, directive
        manipulateSettingsData(data)
)


manipulateSettingsData = (data) ->
  $.website_id = data.id
  $('#generateAppKey').on 'click', (e)->
    $.randomKey = randomString()
    while jQuery.inArray($.randomKey, gon.keys) >= 0
      $.randomKey = randomString()
    $('.app_key').html $.randomKey

  $('#saveAppKey').on 'click', (e)->
    e.preventDefault();
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
