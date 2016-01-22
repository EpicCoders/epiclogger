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

replaceHtmlText = (selected, replace_with) ->
  $.each $('.platform-code'), (index, code) ->
    $(code).html($(code).html().replace( selected, replace_with))

updatePlatform = (website_id) ->
  $('#finish').on 'click', () ->
    visibleTab = $('li.active:visible a').attr('name') || $.platform[0].toUpperCase() + $.platform.slice(1)
    $.ajax
      url: Routes.api_v1_website_url(website_id)
      type: 'put'
      dataType: 'json'
      data: { website: { platform: visibleTab }}
      success: (data) ->
        swal("Good job!", "You will recieve notifications as soon as something will happen on your website.","success")
        setTimeout (->
          location.href = '/errors'
          return
        ), 2000
    return

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action

  switch gon.action
    when "new"
      changeButtonValue()
      $('#myModal').modal('show')
      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data, directive
        updatePlatform(website.id)
        $('.tabs').hide()

        replaceHtmlText(/{app_key}/g, data.app_key)
        replaceHtmlText(/{app_id}/g, data.app_id)
        replaceHtmlText(/{id}/g, data.id)
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

$('li').on 'click', (e) ->
  $('.tabs').hide()
  $(e.target).tab('show')
  $($(e.target).attr('href')).show()

$('.tab').hide()
# $('.tab2, .tab3').addClass('disabled')

$('#client-frameworks a').on 'click', (e) ->
  $('.tab3').removeClass('disabled')
  goToStep(3)
  $(this.name).show()
  $($("a[href='"+$(this).attr('href')+"']")[1]).tab('show')
  $($(this).attr('href')).show()

$('#back, .tab2').on 'click', () ->
  $('.tab').hide()
  $('.tabs').hide()
  $('.tab3').addClass('disabled')
  goToStep(2)

$('#platform a, .tab3').on 'click', (e) ->
  $('.tab3').removeClass('disabled')
  goToStep(3)
  $.platform = this.name
  $('#'+this.name).show()
  $('#'+this.name + 'tab').show()

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
      replaceHtmlText(/{app_key}/g, data.app_key)
      replaceHtmlText(/{app_id}/g, data.app_id)
      replaceHtmlText(/{id}/g, data.id)
    error: (error) ->
      sweetAlert("Error", "Website exists!", "error") if error.status == 401
  return
return