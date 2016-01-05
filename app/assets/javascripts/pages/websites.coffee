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
      $('#formWebsite').submit (e) ->
        e.preventDefault()
        form = $('#formWebsite')
        $.ajax
          url: Routes.api_v1_websites_url()
          type: 'post'
          dataType: 'json'
          data: { website: { domain: form.find('#domain').val(), title: form.find('#title').val() } }
          success: (data) ->
            EpicLogger.setMemberDetails(data.id)
            swal("Success", "Website added!", "success")
            setTimeout (->
              location.href = '/installations'
              return
            ), 2000
          error: (error) ->
            sweetAlert("Error", "Website exists!", "error") if error.status == 401
        return
      return
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        console.log 'data loaded'

)

