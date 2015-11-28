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

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "new"
      addNewWebsite('#formWebsite', 'new')
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        $('#myModal').modal('show') if data.websites.length > 0
        console.log 'data loaded'

      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data

      reset_platforms()
      $('.tab2, .tab3').addClass('disabled')
      addNewWebsite('#modalWebsite', 'index')

)
addNewWebsite = (form, action) ->
  $(form).submit (e) ->
      e.preventDefault()
      $.ajax
        url: Routes.api_v1_websites_url()
        type: 'post'
        dataType: 'json'
        data: { website: { domain: $(form).find('#domain').val(), title: $(form).find('#title').val() } }
        success: (data) ->
          EpicLogger.setMemberDetails(data.id)
          if action == 'index'
            manipulateWizard(2)
            $('.tab1').addClass('disabled')
            $('.tab2').removeClass('disabled')
          else
            alert 'Website added!'
            location.href = '/installations'
        error: (error) ->
          alert "Website exists!" if error.status == 401
      return
    return

reset_platforms = () ->
  $('#javascript, #node_js, #rails, #ruby, #python, #ios, #php, #java, #django').hide()

$('#retry').on 'click', () ->
  manipulateWizard(2)
  reset_platforms()

$('#finish').on 'click', () ->
  location.href = '/errors'

$('#platform').on 'click', (platform) ->
  reset_platforms()
  switch platform.target.parentElement.name
    when 'javascript'
      $('#javascript').show()
    when 'node_js'
      $('#node_js').show()
    when 'rails'
      $('#rails').show()
    when 'ruby'
      $('#ruby').show()
    when 'python'
      $('#python').show()
    when 'ios'
      $('#ios').show()
    when 'php'
      $('#php').show()
    when 'java'
      $('#java').show()
    when 'django'
      $('#django').show()
  manipulateWizard(3)

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
    when "new"
      addNewWebsite('#formWebsite', 'new')
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        $('#myModal').modal('show') if data.websites.length == 0
        console.log 'data loaded'
      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data

      reset_platforms()
      $('.tab2, .tab3').addClass('disabled')
      addNewWebsite('#modalWebsite', 'index')

)
addNewWebsite = (form, action) ->
  $(form).submit (e) ->
      e.preventDefault()
      $.ajax
        url: Routes.api_v1_websites_url()
        type: 'post'
        dataType: 'json'
        data: { website: { domain: $(form).find('#domain').val(), title: $(form).find('#title').val() } }
        success: (data) ->
          EpicLogger.setMemberDetails(data.id)
          if action == 'index'
            manipulateWizard(2)
            $('.tab1').addClass('disabled')
            $('.tab2').removeClass('disabled')
          else
            alert 'Website added!'
            location.href = '/installations'
        error: (error) ->
          alert "Website exists!" if error.status == 401
      return
    return

reset_platforms = () ->
  $('#javascript, #node_js, #rails, #ruby, #python, #ios, #php, #java, #django').hide()

$('#retry').on 'click', () ->
  manipulateWizard(2)
  reset_platforms()

$('#finish').on 'click', () ->
  location.href = '/errors'

$('#platform').on 'click', (platform) ->
  reset_platforms()
  switch platform.target.parentElement.name
    when 'javascript'
      $('#javascript').show()
    when 'node_js'
      $('#node_js').show()
    when 'rails'
      $('#rails').show()
    when 'ruby'
      $('#ruby').show()
    when 'python'
      $('#python').show()
    when 'ios'
      $('#ios').show()
    when 'php'
      $('#php').show()
    when 'java'
      $('#java').show()
    when 'django'
      $('#django').show()
  manipulateWizard(3)

manipulateWizard = (n) ->
  if n != 0
    $('.stepwizard-row a').removeClass('btn-primary')
    $('.stepwizard-row a').addClass('btn-default')
    $('.stepwizard a[href="#step-' + n + '"]').tab 'show'
    $('.stepwizard-row a[href="#step-' + n + '"]').removeClass 'btn-default'
    $('.stepwizard-row a[href="#step-' + n + '"]').addClass 'btn-primary'
  return
