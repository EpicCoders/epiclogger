directive = {
  websites:{
    website_row:
      id: (params)->
        "website_" + this.id
    delete_website:
      href: (params) ->
        Routes.api_v1_website_path(this.id, {format: 'js'})
  }
  events_dsn:
    html: ()->
      '<span class="line">https://' + this.app_key + ':' + this.app_id + '@test-sentry89.herokuapp.com/' + this.id + '</span>'
  public_dsn:
    html: ()->
      '<span class="line">https://' + this.app_key + '@test-sentry89.herokuapp.com/' + this.id + '</span>'
  js_client_configuration:
    html: ()->
      "&lt;script&gt;<br />Raven.config('https://"+this.app_key+"@test-sentry89.herokuapp.com/"+this.id+"', {<br />
      # we highly recommend restricting exceptions to a domain in order to filter out clutter<br />
      whitelistUrls: [/example\.com/]<br />}).install();<br />&lt;/script&gt;"
  node_client_configuration:
    html: ()->
      "var raven = require('raven');<br /><br />var client = new raven.Client('https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"');"
}
changeButtonValue = () ->
  $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
    if data.websites.length > 0
      $('#custom-button').text('Go back')
      $('#custom-button').removeAttr('onclick')
      $('#custom-button').attr('href', '/websites')

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "new"
      changeButtonValue()
      $('#myModal').modal('show')
      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data, directive
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        console.log 'data loaded'

)

goToStep = (n) ->
  if n != 0
    $('.stepwizard-row a').removeClass('btn-primary')
    $('.stepwizard-row a').addClass('btn-default')
    $('.tab'+n).attr('disabled', false)
    $('.stepwizard a[href="#step-' + n + '"]').tab 'show'
    $('.stepwizard-row a[href="#step-' + n + '"]').removeClass 'btn-default'
    $('.stepwizard-row a[href="#step-' + n + '"]').addClass 'btn-primary'
  return

$('.tab').hide()
# $('.tab2, .tab3').addClass('disabled')

$('#back, .tab2').on 'click', () ->
  $('.tab').hide()
  $('.tab3').addClass('disabled')
  goToStep(2)

$('#finish').on 'click', () ->
  location.href = '/errors'

$('#platform a, .tab3').on 'click', (e) ->
  $('.tab').hide()
  $('#'+this.name).show()
  goToStep(3)
  $('.tab3').removeClass('disabled')


$('#addWebsite').submit (e) ->
  e.preventDefault()
  $.ajax
    url: Routes.api_v1_websites_url()
    type: 'post'
    dataType: 'json'
    data: $('#addWebsite').serialize()
    success: (data) ->
      EpicLogger.setMemberDetails(data.id)
      goToStep(2)
      $('.tab1').addClass('disabled')
      $('.tab2').removeClass('disabled')
    error: (error) ->
      sweetAlert("Error", "Website exists!", "error") if error.status == 401
  return
return