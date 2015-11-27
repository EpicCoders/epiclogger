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


$('#platform').on 'click', (platform) ->
  manipulateWizard(3)
  switch platform.target.parentElement.name
    when 'javascript'
      reset_platforms()
      $('#javascript').show()
    when 'nod_js'
      reset_platforms()
      $('#nod_js').show()
    when 'rails'
      reset_platforms()
      $('#rails').show()
    when 'ruby'
      reset_platforms()
      $('#ruby').show()
    when 'python'
      reset_platforms()
      $('#python').show()
    when 'ios'
      reset_platforms()
      $('#ios').show()
    when 'php'
      reset_platforms()
      $('#php').show()
    when 'java'
      reset_platforms()
      $('#java').show()
    when 'django'
      reset_platforms()
      $('#django').show()

reset_platforms = () ->
  $('#javascript, #node_js, #rails, #ruby, #python, #ios, #php, #java, #django').hide()

manipulateWizard = (n) ->
  if n != 0
    $('.stepwizard-row a').removeClass('btn-primary')
    $('.stepwizard-row a').addClass('btn-default')
    $('.stepwizard a[href="#step-' + n + '"]').tab 'show'
    $('.stepwizard-row a[href="#step-' + n + '"]').removeClass 'btn-default'
    $('.stepwizard-row a[href="#step-' + n + '"]').addClass 'btn-primary'
  return


PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        console.log 'data loaded'
    when "new"
      reset_platforms()
      $('#retry').on 'click', () ->
        manipulateWizard(2)
        reset_platforms()

      $('.tab2, .tab3').addClass('disabled')
      $('#addWebsite').submit (e) ->
        e.preventDefault()
        $.ajax
          url: Routes.api_v1_websites_url()
          type: 'post'
          dataType: 'json'
          data: { website: { domain: $('#addWebsite').find('#domain').val(), title: $('#addWebsite').find('#title').val() } }
          success: (data) ->
            manipulateWizard(2)
            $('.tab1').addClass('disabled')
            $('.tab2').removeClass('disabled')
            EpicLogger.setMemberDetails(data.id)
          error: (error) ->
            alert "Website exists!" if error.status == 401
        return

)


# console.log "errors here"
# $('#addWebsite').submit (e) ->
#   e.preventDefault()
#   $.ajax
#     url: Routes.api_v1_websites_url()
#     type: 'post'
#     dataType: 'json'
#     data: { website: { domain: $('#addWebsite').find('#domain').val(), title: $('#addWebsite').find('#title').val() } }
#     success: (data) ->
#       EpicLogger.setMemberDetails(data.id)
#   return
# return