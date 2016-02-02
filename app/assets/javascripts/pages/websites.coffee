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
changeButtonValues = (step) ->
  a = $($('ul[role="menu"] li a')[0])
  switch step
    when 3
      $('#steps-uid-0-t-1').parent().addClass('disabled')
      $('ul[role="menu"]').show()
      a.text('Prev')
      a.attr('onclick', 'EpicLogger.hideFormUl()')
      a.attr('href', '#previous')
    when 1
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        li = $($('ul[role="menu"] li')[0])
        if data.websites.length > 0
          a.text('Go Back')
          li.removeClass('disabled')
          a.attr('onclick', 'location.href = "/websites"')

replaceHtmlText = (selected, replace_with) ->
  $.each $('.platform-code'), (index, code) ->
    $(code).html($(code).html().replace( selected, replace_with))

createWebsite = () ->
  $.ajax
    url: Routes.api_v1_websites_url()
    type: 'post'
    dataType: 'json'
    data: $('#wizard-form').serialize()
    success: (data) ->
      $('#wizard-form').children('div').steps('next', 2)
      # $('#steps-uid-0-t-0').parent().addClass('disabled')
      $('ul[role="menu"]').hide()
      EpicLogger.setMemberDetails(data.id)
      $.website = data
    error: (error) ->
      # debugger
      sweetAlert("Error status 401!", "Bad url or website already exists!", "error")
      return false
  return

chosePlatform = () ->
  $('li').on 'click', (e) ->
    $('.tabs').hide()
    $(e.target).tab('show')
    $($(e.target).attr('href')).show()

  $('#client-frameworks a').on 'click', (e) ->
    $(this.name).show()
    $($("a[href='"+$(this).attr('href')+"']")[1]).tab('show')
    changeButtonValues(3)
    $.element = $(this).attr('href')

  $('#platform a').on 'click', (e) ->
    $.platform = this.name
    $('.tab').hide()
    $(this.name).show()
    changeButtonValues(3)
    $.element = this.name

updatePlatform = () ->
  visibleTab = $(visibleTab = $('li.active:visible a')[1]).attr('name') || $.platform[1].toUpperCase() + $.platform.slice(2)
  $.ajax
    url: Routes.api_v1_website_url($.website.id)
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
      changeButtonValues(1)
      $('.tabs').hide()
      chosePlatform()

    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        console.log 'data loaded'
)

form = $('#wizard-form')
currentStep = 0
goToStep(currentStep)

# form.validate
#   errorPlacement: (error, element) ->
#     element.before error
#     return
#   rules: confirm: equalTo: '#password'

wizardValidate = (step)->
  # if valid then showStep(step)
  # else alert with error

goToStep = (step) ->
  form.children('.step').hide()
  wizardValidate(step)

showStep = (step) ->
  form.children('.step').eq(step).show()

next = ()->
  return if currentStep == form.children('.step').length
  goToStep(currentStep + 1)

prev = ()->
  return if currentStep == 0
  goToStep(currentStep - 1)
# form.children('div').steps
#   headerTag: 'h3'
#   bodyTag: 'section'
#   transitionEffect: 'slideLeft'
#   onInit: (event, currentIndex) ->
#     a = $($('ul[role="menu"] li a')[0])
#     li = $($('ul[role="menu"] li')[0])
#     a.text('Logout')
#     li.removeClass('disabled')
#     a.attr('onclick', 'EpicLogger.logout()')

#   onStepChanging: (event, currentIndex, newIndex) ->
#     #TODO find why return false is trigered after going to next step
#     $('.tab').hide()
#     switch currentIndex
#       when 0
#         createWebsite()
#         return false
#     form.validate().settings.ignore = ':disabled,:hidden'
#     form.valid()
#   onStepChanged: (event, currentIndex, priorIndex) ->
#     switch currentIndex
#       when 1
#         replaceHtmlText(/{app_key}/g, $.website.app_key)
#         replaceHtmlText(/{app_id}/g, $.website.app_id)
#         replaceHtmlText(/{id}/g, $.website.id)
#       when 2
#         $($.element).show()
#         $($.element + 'tab').show()

#   onFinishing: (event, currentIndex) ->
#     updatePlatform()
#     form.validate().settings.ignore = ':disabled'
#     form.valid()
#   onFinished: (event, currentIndex) ->
#     swal('Plarform picked', 'We will notify you as soon as something happens on your website!', 'success')
#     setTimeout (->
#       location.href = '/errors'
#       ), 2000
#     return
