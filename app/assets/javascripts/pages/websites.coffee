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
        console.log 'data loaded'

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

