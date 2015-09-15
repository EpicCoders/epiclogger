# important don't add $ -> here when using PubSub as the event will be assigned every time
directive = {
  groups:{
    warning: {
      href: (params) ->
        Routes.error_path(this.id)
    }
    last_occurrence:
      html: ()->
        moment(this.last_occurrence).calendar()
  },
  group:{
    # warning: {
    #   href: (params) ->
    #     Routes.grouped_issue_path(this.id)
    # }
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
      request(website.id, page)
      $('.next').on 'click', () ->
        page = page + 1
        request(website.id, page)
      $('.previous').on 'click', () ->
        page = page - 1
        request(website.id, page)
    when 'show'
      $.getJSON '/api/v1/errors/' + gon.error_id, { website_id: website.id }, (data) ->
        $('#grouped-issuedetails').render data, directive
        $('#missing-errors').hide() if data != 0
)

request = (website_id, page) ->
  $.getJSON Routes.api_v1_errors_path(), { website_id: website_id, page: page }, (data) ->
    render(data)

render = (data) ->
  $.obj = data
  if data.groups.length > 0
    $('#missing-errors').hide()

    # start the pagination
    $('.pagination-text').html(data.page + '/' + data.pages)
    $('.next').addClass('disabled') if data.page == data.pages
    $('.next').removeClass('disabled') if data.page != data.pages
    $('.previous').removeClass('disabled') if data.page != 1
    $('.previous').addClass('disabled') if data.page == 1
  else
    $('#missing-errors').show()
  $('#grouped-issuescontainer').render data, directive

# SortByUsersSubscribed = (a, b) ->
#   aError = a.users_count
#   bError = b.users_count
#   if aError < bError then 1 else if aError > bError then -1 else 0

SortByLastOccurrence = (a, b) ->
  aTime = a.last_occurrence
  bTime = b.last_occurrence
  if aTime < bTime then 1 else if aTime > bTime then -1 else 0

$('select#sortinput').change ->
  theValue = $('option:selected').text()
  console.log theValue
  if theValue == "Last occurrence"
    $('#grouped-issues').render $.obj.grouped_issues.sort(SortByLastOccurrence), directive
  # else if theValue == "Users subscribed"
  #   $('#grouped-issues').render $.obj.grouped_issues.sort(SortByUsersSubscribed), directive
  return

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
