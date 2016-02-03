replaceHtmlText = (selected, replace_with) ->
  $.each $('.platform-code'), (index, code) ->
    $(code).html($(code).html().replace( selected, replace_with))

websiteChanged = (website) ->
  return true if $('#domain').attr('value') != website.domain
  return true if $('#title').attr('value') != website.title
  return true if $('#platform').text().replace(/\s/g, '') != website.platform
  return false

editWebsite = (website) ->
  $.website = website
  $('#edit-website').on 'click', (e) ->
    e.preventDefault()
    if websiteChanged($.website)
      $.ajax
        url: Routes.api_v1_website_url($.website.id)
        type: 'put'
        dataType: 'json'
        data: $('#formWebsite').serialize()
        success: (data) ->
          EpicLogger.setMemberDetails(data.id)
          swal("Success!", "Website settings updated!", "success")
          setTimeout (->
            location.href = '/installations'
            return
          ), 2000
    else
      swal("Notification", "Make a change to your website before editing", "warning")

generateApiKey = (data) ->
  $.website_id = data.id
  $('#generateAppKey, #revoke').on 'click', (e)->
    e.preventDefault();
    $.ajax
      data: {website: {id: $.website_id, generate: true}}
      url: Routes.api_v1_website_url($.website_id)
      type: 'PUT'
      success: (result)->
        swal('Key updated')
        setTimeout (->
          location.href = '/installations'
          return
        ), 2000
    return

handleEditDetails = (website_id) ->
  $.getJSON Routes.api_v1_website_path(website_id), (data) ->
    $('#owner').render data
    replaceHtmlText(/{app_key}/g, data.app_key)
    replaceHtmlText(/{app_secret}/g, data.app_secret)
    replaceHtmlText(/{id}/g, data.id)

    editWebsite(data)
    generateApiKey(data)

    $('input[name=daily]').attr('checked', true) if data.daily
    $('input[name=realtime]').attr('checked', true) if data.realtime
    $('input[name=new_event]').attr('checked', true) if data.new_event
    $('input[name=frequent_event]').attr('checked',true) if data.frequent_event
    $('#save').prop('disabled', true)
    $('#current-website').render data
    $('#platform').html(data.platform + ' <span class="caret"></span>')
    $('#owner').html(data.owners[0].email+ ' <span class="caret"></span>')

  $('input').change ->
    $('#save').prop('disabled', false)

  $('#save').on 'click', (e) ->
    e.preventDefault()
    $.ajax
      url: Routes.api_v1_website_path(website_id)
      type: 'put'
      dataType: 'json'
      data: {
        website: {
          daily: $('input[name=daily]').is(':checked'),
          realtime: $('input[name=realtime]').is(':checked'),
          new_event: $('input[name=new_event]').is(':checked'),
          frequent_event: $('input[name=frequent_event]').is(':checked')
        }
      }
      success: (data) ->
        $('#save').prop('disabled', true)
        swal("Success!", "You will recieve notifications soon.", "success")


PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      handleEditDetails(website.id)
      $('.tab, .main-tabs').hide()
      $('#client-details, #details-tabs, #settings').show()
)

$('.dropdown-menu li a').click ->
  selText = $(this).text()
  $(this).parents('.dropdown').find('.dropdown-toggle').html(selText + ' <span class="caret"></span>')
  return

switchTab = (target,location) ->
  $('.tab').hide()
  $(target).tab('show')
  tag = $(target).attr('href')
  $(tag).show()
  $('#'+this.name+'tab').show()
  return

$('#top-tabs a').on 'click', (e) ->
  e.preventDefault()
  $('.main-tabs').hide()
  $(this).tab('show')
  $($(this).attr('href')).show()
  ul = $($($(this).attr('href')+' ul')[0])
  ul.show()
  content = $("#"+ ul.attr('id')+' li.active a').attr('href')
  $(content).show()

$('#client-configuration li').on 'click', (e) ->
  $('.tabs').hide()
  $(this).tab('show')
  $(this).addClass('active')
  $($(this).find('a').attr('href')).show()
  $($(this).find('a').attr('href') + 'tab').show()

$('#platforms-tabs a').click (e) ->
  e.preventDefault()
  switchTab(e.target,'platforms')

$('#details-tabs a').click (e) ->
  e.preventDefault()
  switchTab(e.target,'details')

$('#img-platforms a').on 'click', (e) ->
  $('.tab').hide()
  attr = $(this).attr('href')
  $($("a[href='"+attr+"']")[0]).tab('show')
  $(attr).show()
  $(attr+'tab').show()

$('#client-frameworks a').on 'click', (e) ->
  $('.tab').hide()
  $(this.name).show()
  attr = $(this).attr('href')
  $($("a[href='"+attr+"']")[1]).tab('show')
  $('.tabs').hide()
  $(attr).show()
