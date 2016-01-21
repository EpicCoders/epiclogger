replaceHtmlText = (selected, replace_with) ->
  $.each $('.platform-code'), (index, code) ->
    $(code).html($(code).html().replace( selected, replace_with))

PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      createWebsite()
      $('.tab, .main-tabs').hide()
      $('#client-configuration, #platforms-tabs, #all-platforms').show()

      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('input[name=daily]').attr('checked', true) if data.daily
        $('input[name=realtime]').attr('checked', true) if data.realtime
        $('input[name=new_event]').attr('checked', true) if data.new_event
        $('input[name=frequent_event]').attr('checked',true) if data.frequent_event
        $('#save, #add-website').prop('disabled', true)
        $('#current-website').render data
        generateApiKey(data)

        replaceHtmlText(/{app_key}/g, data.app_key)
        replaceHtmlText(/{app_id}/g, data.app_id)
        replaceHtmlText(/{id}/g, data.id)

      $('#title, #domain').change ->
        $('#add-website').prop('disabled', false)

      $('input').change ->
        $('#save').prop('disabled', false)

      $('#save').on 'click', (e) ->
        e.preventDefault()
        $.ajax
          url: Routes.api_v1_website_path(website.id)
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
)

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

createWebsite = () ->
  $('#add-website').on 'click', (e) ->
    e.preventDefault()
    domain_url = $('#formWebsite').find('#domain').val()
    url_title = $('#formWebsite').find('#title').val()
    if (domain_url.replace(/\s+/g, '') || url_title.replace(/\s+/g, '')) == null || (domain_url.replace(/\s+/g, '') || url_title.replace(/\s+/g, '')) == ""
      swal("A valid website is is needed.")
      setTimeout (->
          location.href = '/installations'
          return
        ), 2000
    else
      $.ajax
        url: Routes.api_v1_websites_url()
        type: 'post'
        dataType: 'json'
        data: { website: { domain: domain_url, title: url_title } }
        success: (data) ->
          EpicLogger.setMemberDetails(data.id)
          swal("Good job!", "Website added!", "success")
          $('#add-website').prop('disabled', true)
          setTimeout (->
            location.href = '/installations'
            return
          ), 2000
        error: (error) ->
          sweetAlert("Error", "Website exists", "error") if error.status == 401


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
  li = $('#client-configuration li').slice(8)
  $(this).tab('show')
  $('.tabs').hide()
  $($(this).find('a').attr('href')).show()
  $($(this).find('a').attr('href') + 'tab').show()

$('#platforms-tabs a').click (e) ->
  e.preventDefault()
  toggleTabs( e.target,'platforms' )

$('#details-tabs a').click (e) ->
  e.preventDefault()
  toggleTabs( e.target,'details' )

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

toggleTabs = (target,location) ->
  $('.tab').hide()
  $(target).tab('show')
  tag = $(target).attr('href')
  $(tag).show()
  $('#'+this.name+'tab').show()
  return