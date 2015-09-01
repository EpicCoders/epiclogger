# important don't add $ -> here when using PubSub as the event will be assigned every time

directive = {
  errors:{
    warning: {
      href: (params) ->
        Routes.error_path(this.id)
    }
    occurrences:
      html: () ->
        "#{this.occurrences} occurrences"
    users_count:
      html: ()->
        "#{this.users_count} users subscribed"
    last_occurrence:
      html: ()->
        moment(this.last_occurrence).calendar()
  },
  created_at:
    html: ()->
      moment(this.created_at).calendar()
  last_occurrence:
    html: ()->
      moment(this.last_occurrence).calendar()
  subscribers_count:
    html: ()->
      "Send an update to #{this.subscribers_count} subscribers"
}
PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      page = 1
      $.getJSON '/api/v1/errors', { website_id: website.id, page: page }, (data) ->
        render(data)
      $('.next').on 'click', () ->
        page = page + 1
        request(website.id, page)
      $('.previous').on 'click', () ->
        page = page - 1
        request(website.id, page)
    when 'show'
      $.getJSON '/api/v1/errors/' + gon.error_id, { website_id: website.id }, (data) ->
        $('#errordetails').render data, directive
)

request = (website_id, page) ->
  $.getJSON '/api/v1/errors', { website_id: website_id, page: page }, (data) ->
    render(data)

render = (data) ->
  if data.errors.length > 0
    $('#missing-errors').hide()

    # start the pagination
    $('.pagination-text').html(data.page + '/' + data.pages)
    $('.next').addClass('disabled') if data.page == data.pages
    $('.next').removeClass('disabled') if data.page != data.pages
    $('.previous').removeClass('disabled') if data.page != 1
    $('.previous').addClass('disabled') if data.page == 1
  else
    $('#missing-errors').show()
  $('#errorscontainer').render data, directive

$('#solve').on 'click', (e)->
  e.preventDefault();
  $.ajax
    data: {error: {status: 'resolved'}}
    url: Routes.api_v1_error_url(gon.error_id)
    type: 'PUT'
    success: (result)->
      alert 'Status updated'
  return

$('.messageTextarea').keydown((event) ->
  if event.keyCode == 13
    $('#notify').submit()
    return false
  return
).focus(->
  if @value == ''
    @value = ''
  return
).blur ->
  if @value == ''
    @value = ''
  return
$('form#notify').submit ->
  dataString = $('.messageTextarea').val()
  $.ajax
    url: Routes.notify_subscribers_api_v1_error_url(gon.error_id)
    type: 'POST'
    data: {message: dataString}
    success: (data) ->
      # finish load
      return
  false
