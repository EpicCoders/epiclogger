# important don't add $ -> here when using PubSub as the event will be assigned every time
directive = {
  groups:{
    warning: {
      href: (params) ->
        Routes.error_path(this.id)
    }
    last_occurrence:
      html: ()->
        moment(this.last_seen).calendar()
  },
  created_at:
    html: ()->
      moment(this.created_at).calendar()
  last_occurrence:
    html: ()->
      moment(this.last_seen).calendar()
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
#default starting page
page = 1

#the number of errors displayed in one sidebar page
errors_per_page = 14

PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      request(website.id, page)
      $('.next').on 'click', () ->
        page = page + 1
        request(website.id, page)
      $('.previous').on 'click', () ->
        page = page - 1
        request(website.id, page)
    when 'show'
      individualErrorSidebar()
      setUpErrorSidebar($(window).width())
      $.getJSON '/api/v1/errors/' + gon.error_id, { website_id: website.id }, (data) ->
        $.current_issue = data.id
        firsttime_sidebar_request(website.id,page,errors_per_page,data.last_seen)
        manipulateShowElements(data)
        $('#grouped-issuedetails').render data, directive
        populateSidebar(data)
        sidebar_request(website.id,page,$.current_issue,13)

      $('#solve').on 'click', (e)->
        e.preventDefault();
        $('#solve').hide()
        $('.resolved').show()
        $('.notify').attr('disabled', 'disabled')
        $.ajax
          data: {error: {status: 'resolved'}}
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

      $('.next').on 'click', () ->
        page = page + 1
        sidebar_request(website.id, page, errors_per_page)
      $('.previous').on 'click', () ->
        page = page - 1
        sidebar_request(website.id, page, errors_per_page)
)

request = (website_id, page) ->
  $.getJSON Routes.api_v1_errors_path(), { website_id: website_id, page: page }, (data) ->
    manipulateIndexElements(data)

#workaround
firsttime_sidebar_request = (website_id, page, error_count, current_issue) ->
  $.getJSON Routes.api_v1_errors_path(), { website_id: website_id, page: page, error_count: error_count, current_issue: current_issue }, (data) ->
    page = data.page
    initializeSidebarButtons(data.page,website_id)
    errorSidebarPagination(data)
    populateSidebar(data)

sidebar_request = (website_id, page, error_count, current_issue) ->
  $.getJSON Routes.api_v1_errors_path(), { website_id: website_id, page: page, error_count: error_count, current_issue: current_issue }, (data) ->
    page = data.page
    errorSidebarPagination(data)
    populateSidebar(data)

getAvatars = (data) ->
  $.src = []
  $.each data.issues, (index, data) ->
    $.src.push(data.subscriber.avatar_url)
  # $.each $.src, (index, avatar_url) ->
  #   $('img').attr('src', avatar_url)
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
    $('#grouped-issues').show()
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
  $('#grouped-issuescontainer').render data, directive


changeError = (el) ->
  if $.current_issue != parseInt($(el).find("input").val())
    $(el).addClass("current_issue")
    $('input[value="' + $.current_issue + '"]').parent().removeClass('current_issue')
    window.location.replace(window.location.origin + "/errors/" + $(el).find("input").val())

setUpErrorSidebar = (width) ->
  if width >= 1170
    $('.cbp-spcontent').css('max-width','calc(100% - 300px)')
    $('.error-menu').removeClass('error-menu-hidden')
    $('.error-menu').removeClass('error-menu-visible')
    $('.cbp-spcontent').removeClass('content-mobile')
    $('.cbp-spcontent').removeClass('content-fullwidth')
    $('.error-menu').addClass('error-menu-partial')
    $('.cbp-spcontent').addClass('content-partial')
  else
    $('.cbp-spcontent').css('max-width','none')
    $('.error-menu').removeClass('error-menu-partial')
    $('.cbp-spcontent').removeClass('content-partial')
    $('.error-menu').addClass('error-menu-hidden')
    $('.cbp-spcontent').addClass('content-mobile')


individualErrorSidebar = () ->
  $(window).unbind().on 'resize', (e) ->
    if gon.action == "show" and gon.controller == "errors"
      setUpErrorSidebar($(window).width())
  $(document).ready ->
    if gon.action == "show" and gon.controller == "errors"
      setUpErrorSidebar($(window).width())
  $('.toggle-left-sidebar').unbind('click').on 'click', () ->
    $('.toggle-left-sidebar').toggleClass('toggle-left-sidebar-open')
    $('.error-menu').toggleClass('error-menu-visible')
    $('.cbp-spcontent').toggleClass('content-fullwidth')
    if $(window).width() < 1170
      $('.cbp-spcontent').toggleClass('content-mobile')

initializeSidebarButtons = (page,website) ->
  $('.next').on 'click', () ->
    page = page + 1
    sidebar_request(website, page, errors_per_page)
  $('.previous').on 'click', () ->
    page = page - 1
    sidebar_request(website, page, errors_per_page)

errorSidebarPagination = (data) ->
  if data.groups.length > 0
    $('.sidebar_pagination_text').html(data.page + '/' + data.pages)
    if data.page == data.pages
      $('.next').addClass('disabled').prop("disabled",true)
    else
      $('.next').removeClass('disabled').prop("disabled",false)
    if data.page == 1
      $('.previous').addClass('disabled').prop("disabled",true)
    else
      $('.previous').removeClass('disabled').prop("disabled",false)
  else
    $('.sidebar_pagination_text').html('0/0')
    $('.next').addClass('disabled').prop("disabled",true)
    $('.previous').addClass('disabled').prop("disabled",true)

populateSidebar = (data) ->
  $('.sidebar_elements').empty()
  $.each data.groups , (index, issue) ->
    message = {}
    message.type = issue.message.split(":")[0]
    message.content = issue.message.split(":")[1]
    website_domain = issue.website_domain.split("http://")[1]
    container = "<div class='sidebar-container'>
                  <input value='" + issue.id + "' type='hidden'>
                  <div class='sidebar-container-header'>
                    <i class='icon-" + issue.platform + " header-icon'></i>
                    <span class='pull-right muted'>" + moment(issue.last_seen,"YYYY-MM-DDTHH:mm:ssZ").format("HH:mm MMM D YYYY") + " </span>
                  </div>
                  <div class='sidebar-container-content panelbox'>
                    <p class='error-title'>" + "<b>" + message.type + "</b>" + "<span class='website-content pull-right'>  (" + website_domain + ")</span>" + "</p>
                  </div>
                </div>"
    $('.sidebar_elements').append(container)
    if issue.id == $.current_issue
      $('.sidebar-container').last().addClass("current_issue")
    $('.sidebar-container').click ->
      changeError(this)

errorStacktrace = (data) ->
  issue_nr =0
  if data.issues.length > 0
    $.each data.issues[0].description, (index, issue) ->
      issue_nr+=1
      button = ' <button class="btn btn-warning btn-xs glyphicon glyphicon-plus" data-target="#expand_'+issue_nr+'"+ data-toggle="collapse" title="Click to expand"> View source</button>'
      $('<p>' + issue.filename + ' ? in ' + issue.function + ' at line ' + issue.lineno + '/' + issue.colno + '</p>' + button).prependTo '.stacktrace'
    object_nr =0
    $.each data.issues[0].data, (index, object) ->
      object_nr+=1
      $('.stacktrace_error').append("<div class=collapse id='expand_"+object_nr+"'></div>")
      $.each object, (key, value) ->
        $('#expand_' + object_nr).text value


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
