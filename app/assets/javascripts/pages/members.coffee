console.log "members loaded"
$('.signup-github').on('click', ()->
  $.auth.oAuthSignIn({provider: 'github'})
)
form_signup = $('#signup')
form_signup.submit((e)->
  e.preventDefault()

  $.auth.emailSignUp(
    name: form_signup.find('#name').val()
    email: form_signup.find('#email').val()
    password: form_signup.find('#password').val()
    password_confirmation: form_signup.find('#passwod_confirm').val()
  ).then((resp) ->
    console.log "we have success"
    console.log resp
    $.ajax
      url: Routes.api_v1_members_url()
      type: 'post'
      dataType: 'json'
      data: { website_member: { website_id: gon.website_id, token: gon.token, email: form_signup.find('#email').val() } }
      success: (data) ->
        window.location.href = '/websites'
  ).fail ((resp) ->
    EpicLogger.addAlert(resp.data.errors.full_messages)
    console.log "we failed"
    console.log resp
  )
)
directive = {
  members:{
    role:
      html: ()->
        "#{this.role}"
    member_row:
      id: (params)->
        "member_" + this.id
    delete_member:
      href: (params) ->
        Routes.api_v1_member_path(this.id, {format: 'js'})
  }
}

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_members_url(), { website_id: website.id }, (data) ->
        $('#members-container').render data, directive
)

