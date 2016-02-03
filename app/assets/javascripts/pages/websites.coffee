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
  switch step
    when 2
      a = $('ul[role="menu"] li a')
      $(a[0]).text('Prev')
      $(a[0]).removeAttr('onclick')
      $(a[1]).hide()
      $(a[2]).show()
    when 0
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        a = $($('ul[role="menu"] li a')[0])
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
      EpicLogger.setMemberDetails(data.id)
      showStep(0)
      $.website = data
      replaceHtmlText(/{app_key}/g, data.app_key)
      replaceHtmlText(/{app_secret}/g, data.app_secret)
      replaceHtmlText(/{id}/g, data.id)
    error: (error) ->
      sweetAlert("Error!", "Bad url or website already exists!", "error")
  return

chosePlatform = () ->
  $('li').on 'click', (e) ->
    $('.tabs').hide()
    $(e.target).tab('show')
    $($(e.target).attr('href')).show()

  $('#client-frameworks a').on 'click', (e) ->
    showStep(1)
    $('.tab').hide()
    $('.actions').show()
    href = $(this).attr('href')
    $(href).show()
    $(this.name).show()
    $('a[href="'+this.name+'"]').tab('show')
    $.element = $(this).attr('href')


  $('#platform a').on 'click', (e) ->
    showStep(1)
    $('.tab').hide()
    $('.actions').show()
    $(this.name).show()
    $(this.name+'tab').show()
    $.element = this.name

updatePlatform = () ->
  visibleTab = $(visibleTab = $('li.active:visible a')[0]).attr('name') || $.element[1].toUpperCase() + $.element.slice(2)
  $.ajax
    url: Routes.api_v1_website_url($.website.id)
    type: 'put'
    dataType: 'json'
    data: { website: { platform: visibleTab }}
    success: (data) ->
      swal("Great!", "You will recieve notifications as soon as something will happen on your website.","success")
      setTimeout (->
        location.href = '/errors'
        return
      ), 2000
  return


form = $('#wizard-form')
a = $($('ul[role="menu"] li a')[0])
li = $($('ul[role="menu"] li')[0])
a.text('Logout')
li.removeClass('disabled')
a.attr('onclick', 'EpicLogger.logout()')

performStep = (step) ->
  switch step
    when 0
      if $('#wizard-form').valid()
        createWebsite()
        chosePlatform()
    when 2
      updatePlatform()


showStep = (step) ->
  changeButtonValues(2) if step == 1
  tablist = $('ul[role="tablist"] li')
  $(tablist[step]).addClass('done')
  $(tablist[step+1]).addClass('current')
  $($('.step')[step]).hide()
  $($('.step')[step+1]).show()
  $($.element).hide()
  $('.actions').hide()


$('.next').click(-> performStep(0))
$('.prev').click(-> showStep(0))
$('.finish').click(-> performStep(2))

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "new"
      changeButtonValues(0)
      $('.tabs').hide()
      chosePlatform()

    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        $('#missing-websites').hide() if data.websites.length > 0
        console.log 'data loaded'
)
