directive = {
  websites:{
    website_row:
      id: (params)->
        "website_" + this.id
    delete_website:
      href: (params) ->
        Routes.api_v1_website_path(this.id, {format: 'js'})
  }
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
        $('#current-website').render data
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        console.log 'data loaded'

)

goToStep = (n) ->
  if n != 0
    $('.stepwizard-row a').removeClass('btn-primary')
    $('.stepwizard-row a').addClass('btn-default')
    $('.stepwizard a[href="#step-' + n + '"]').tab 'show'
    $('.stepwizard-row a[href="#step-' + n + '"]').removeClass 'btn-default'
    $('.stepwizard-row a[href="#step-' + n + '"]').addClass 'btn-primary'
  return

$('.tab').hide()
$('.tab2, .tab3').addClass('disabled')

$('#back').on 'click', () ->
  $('.tab').hide()
  goToStep(2)

$('#finish').on 'click', () ->
  location.href = '/errors'

$('#platform a').on 'click', (e) ->
  $('.tab').hide()
  $('#'+this.name).show()
  goToStep(3)


$('#modalWebsite').submit (e) ->
  e.preventDefault()
  $.ajax
    url: Routes.api_v1_websites_url()
    type: 'post'
    dataType: 'json'
    data: $('#modalWebsite').serialize()
    success: (data) ->
      EpicLogger.setMemberDetails(data.id)
      goToStep(2)
      $('.tab1').addClass('disabled')
      $('.tab2').removeClass('disabled')
    error: (error) ->
      sweetAlert("Error", "Website exists!", "error") if error.status == 401
  return
return