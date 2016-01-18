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
  created_at:
    html: ()->
      moment(this.created_at).calendar()
  last_occurrence:
    html: ()->
      moment(this.last_occurrence).calendar()
  resolved_at:
    html: ()->
      moment(this.resolved_at).calendar()
  error_title:
    html: ()->
      this.message
  subscribers_count:
    html: ()->
      "Send an update to #{this.subscribers_count} subscribers"
  # issue_subscriber:
  #   html: ()->
  #     "Id: #{this.issues[0].subscriber.id}<br/><br/>IP Adress: 10.156.45.154.. <br/><br/>Email: #{this.issues[0].subscriber.email}<br/><br/>Data: ()"
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
      $.getJSON '/api/v1/errors/' + gon.error_id, { group_id: gon.error_id, website_id: website.id }, (data) ->
        manipulateShowElements(data)
        $('#grouped-issuedetails').render data, directive

      $('#solve').on 'click', (e)->
        e.preventDefault();
        $('#solve').hide()
        $('.resolved').show()
        $('.notify').attr('disabled', 'disabled')
        $.ajax
          data: {website_id: website.id, group_id: gon.error_id, error: {status: 'resolved'}}
          url: Routes.api_v1_error_url(gon.error_id)
          type: 'PUT'
          success: (result)->
            swal("Status updated", "Great job!", "success")
        return

      $('form#notify').submit ->
        dataString = $('.messageTextarea').val()
        $.ajax
          url: Routes.notify_subscribers_api_v1_error_url(gon.error_id)
          type: 'POST'
          data: {website_id: website.id, group_id: gon.error_id, message: dataString}
          success: (data) ->
            $('.messageTextarea').val('')
            return
        false
)

request = (website_id, page) ->
  $.getJSON Routes.api_v1_errors_path(), { website_id: website_id, page: page }, (data) ->
    manipulateIndexElements(data)

getAvatars = (data) ->
  $.src = []
  $.each data.issues, (index, data) ->
    $.src.push(data.subscriber.avatar_url)
  $.each $.src, (index, avatar_url) ->
    $('img').attr('src', avatar_url)
  return $.src

countSubscribers = (data) ->
  subscribers_count = 0
  $.each data.issues, (index, issue) ->
    subscribers_count += issue.subscribers_count
  return subscribers_count

manipulateIndexElements = (data) ->
  $.obj = data
  if data.groups.length > 0
    $('#missing-errors').hide()
    $('#grouped-issuescontainer').render data, directive

    # start the pagination
    $('.pagination-text').html(data.page + '/' + data.pages)
    $('.next').addClass('disabled') if data.page == data.pages
    $('.next').removeClass('disabled') if data.page != data.pages
    $('.previous').removeClass('disabled') if data.page != 1
    $('.previous').addClass('disabled') if data.page == 1
  else
    $('.side').hide()
    $('.buttons').hide()
    $('#grouped-issues').hide()
    $('#missing-errors').show()

manipulateShowElements = (data) ->
  # errorStacktrace(data)
  if data.status == 'resolved'
    $('#solve').hide()
    $('.notify').attr('disabled', 'disabled')
  else
    $('.resolved').hide()
    $('.resolved_at').hide()
  data.avatars = getAvatars(data).slice(0,2)
  data.subscribers_count = countSubscribers(data)
  if data.subscribers_count > 2
    $('#truncate').show()
  else
    $('#truncate').hide()
  $('#truncate').on 'click', (e) ->
    if $('#truncate').text() == "...show more"
      data.avatars = getAvatars(data)
      $('#truncate').text("...show less")
    else
      $('#truncate').text("...show more")
      data.avatars = getAvatars(data).slice(0,2)

SortByUsersSubscribed = (a, b) ->
  aError = a.users_count
  bError = b.users_count
  if aError < bError then 1 else if aError > bError then -1 else 0

SortByLastOccurrence = (a, b) ->
  aTime = a.last_occurrence
  bTime = b.last_occurrence
  if aTime < bTime then 1 else if aTime > bTime then -1 else 0

$('select#sortinput').change ->
  theValue = $('option:selected').text()
  console.log theValue
  if theValue == "Last occurrence"
    $('#grouped-issues').render $.obj.grouped_issues.sort(SortByLastOccurrence), directive
  else if theValue == "Users subscribed"
    $('#grouped-issues').render $.obj.grouped_issues.sort(SortByUsersSubscribed), directive
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

PubSub.subscribe('assigned.website', (ev, website)->
  $.getJSON Routes.api_v1_website_path(website.id), (data) ->
    $('#current-website').render data
)

$('.tab').hide()
$('.tab2, .tab3').addClass('disabled')

$('#back').on 'click', () ->
  $('.tab').hide()
  manipulateWizard(2)

$('#finish').on 'click', () ->
  location.href = '/errors'

$('#platform a').on 'click', (e) ->
  $('.tab').hide()
  $('#'+this.name).show()
  manipulateWizard(3)

manipulateWizard = (n) ->
  if n != 0
    $('.stepwizard-row a').removeClass('btn-primary')
    $('.stepwizard-row a').addClass('btn-default')
    $('.stepwizard a[href="#step-' + n + '"]').tab 'show'
    $('.stepwizard-row a[href="#step-' + n + '"]').removeClass 'btn-default'
    $('.stepwizard-row a[href="#step-' + n + '"]').addClass 'btn-primary'
  return

$('#modalWebsite').submit (e) ->
  e.preventDefault()
  form = $('#modalWebsite')
  $.ajax
    url: Routes.api_v1_websites_url()
    type: 'post'
    dataType: 'json'
    data: { website: { domain: form.find('#domain').val(), title: form.find('#title').val() } }
    success: (data) ->
      EpicLogger.setMemberDetails(data.id)
      manipulateWizard(2)
      $('.tab1').addClass('disabled')
      $('.tab2').removeClass('disabled')
  return
return
