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
          a.removeAttr('href')
          li.removeClass('disabled')
          a.attr('onclick', 'location.href = "/websites"')
        else
          a.text('Logout')
          li.removeClass('disabled')
          a.attr('onclick', 'EpicLogger.logout()')

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
      $('#steps-uid-0-t-0').parent().addClass('disabled')
      $('ul[role="menu"]').hide()
      EpicLogger.setMemberDetails(data.id)
      $.website = data
      auto_refresh = setInterval (->
        replaceHtmlText(/{app_key}/g, $.website.app_key)
        replaceHtmlText(/{app_id}/g, $.website.app_id)
        replaceHtmlText(/{id}/g, $.website.id)
        if $($('.platform-code')[1]).html().indexOf($.website.app_key) >= 0
          clearInterval(auto_refresh)
        return
      ), 200
    error: (error) ->
      sweetAlert("Error status 401!", "Bad url or website already exists!", "error")
      return false
  return

chosePlatform = () ->

  $('.tab').hide()
  $('li').on 'click', (e) ->
    $('.tabs').hide()
    $(e.target).tab('show')
    $($(e.target).attr('href')).show()

  $('#client-frameworks a').on 'click', (e) ->
    $(this.name).show()
    $($("a[href='"+$(this).attr('href')+"']")[1]).tab('show')
    changeButtonValues(3)
    $.element = $(this).attr('href')
    auto_refresh = setInterval (->
      $($.element).show()
      if $($.element).is(':visible')
        clearInterval(auto_refresh)
      return
    ), 100

  $('#platform a').on 'click', (e) ->
    $.platform = this.name
    $('.tab').hide()
    $(this.name).show()
    changeButtonValues(3)
    $.element = this.name
    auto_refresh = setInterval (->
      $($.element + 'tab').show()
      if $($.element+'tab').is(':visible') || $($.element+'tab').length == 0
        clearInterval(auto_refresh)
      return
    ), 100

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
form.validate
  errorPlacement: (error, element) ->
    element.before error
    return
  rules: confirm: equalTo: '#password'

form.children('div').steps
  headerTag: 'h3'
  bodyTag: 'section'
  transitionEffect: 'slideLeft'
  onStepChanging: (event, currentIndex, newIndex) ->
    #TODO find why return false is trigered after going to next step
    switch $("#wizard-form").find("[aria-selected='true']").index()
      when 0
        return false if createWebsite() == false
        $(document).ajaxError (event, jqxhr, settings, exception) ->
          if jqxhr.status == 401
            return false
          else
            $('ul[role="menu"]').hide()
    form.validate().settings.ignore = ':disabled,:hidden'
    form.valid()
  onFinishing: (event, currentIndex) ->
    updatePlatform()
    form.validate().settings.ignore = ':disabled'
    form.valid()
  onFinished: (event, currentIndex) ->
    swal('Plarform picked', 'We will notify you as soon as something happens on your website!', 'success')
    setTimeout (->
      location.href = '/errors'
      ), 2000
    return
