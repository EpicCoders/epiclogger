directive = {
  website_members:{
    member_row:
      id: (params)->
        "member_" + this.id
    delete_member:
      href: (params) ->
        Routes.api_v1_website_member_path( this.id, {format: 'js', website_id: this.website_id})
  }
}
replaceHtmlText = (selected, replace_with) ->
  $.each $('.platform-code'), (index, code) ->
    $(code).html($(code).html().replace( selected, replace_with))

PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      createWebsite(website.id)
      $('.tab, .main-tabs').hide()
      $('#client-details, #details-tabs, #settings').show()
      $.getJSON Routes.api_v1_website_members_url(), { website_id: website.id }, (data) ->
        $('#owners').render data, directive
        $('#owner').html(data.website_members[0].email)
        $('#owner').append('<span class="caret"></span>')

      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('input[name=daily]').attr('checked', true) if data.daily
        $('input[name=realtime]').attr('checked', true) if data.realtime
        $('input[name=new_event]').attr('checked', true) if data.new_event
        $('input[name=frequent_event]').attr('checked',true) if data.frequent_event
        $('#save, #edit-website').prop('disabled', true)
        $('#current-website').render data
        $('#platform').html(data.platform + ' <span class="caret"></span>')
        generateApiKey(data)

        replaceHtmlText(/{app_key}/g, data.app_key)
        replaceHtmlText(/{app_id}/g, data.app_id)
        replaceHtmlText(/{id}/g, data.id)

      $('#title, #domain').change ->
        $('#edit-website').prop('disabled', false)

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

$('.dropdown-menu li a').click ->
  selText = $(this).text()
  $(this).parents('.dropdown').find('.dropdown-toggle').html selText + ' <span class="caret"></span>'
  return

createWebsite = (website_id) ->
  $('#edit-website').on 'click', (e) ->
    e.preventDefault()
    $.ajax
      url: Routes.api_v1_website_url(website_id)
      type: 'put'
      dataType: 'json'
      data: $('#formWebsite').serialize()
      success: (data) ->
        EpicLogger.setMemberDetails(data.id)
        swal("Success!", "Website settings updated!", "success")
        $('#edit-website').prop('disabled', true)
        setTimeout (->
          location.href = '/installations'
          return
        ), 2000


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