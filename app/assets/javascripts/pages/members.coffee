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
    window.location.href = '/websites'
  ).fail ((resp) ->
    EpicLogger.addAlert(resp.data.errors.full_messages)
    console.log "we failed"
    console.log resp
  )
)

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_subscribers_url(), { website_id: website.id }, (data) ->
        $('#members-container').render data
)

