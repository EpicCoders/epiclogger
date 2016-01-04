console.log "members loaded"
$('.signup-github').on('click', ()->
  $.auth.oAuthSignIn({provider: 'github'})
)

$('#signup').validate({
  rules: {
    name: {
      required: true
    },
    email: {
      email: true,
      required: true
    },
    password: {
      minlength: 5,
      required: true
    },
    password_confirm: {
      minlength: 5,
      required: true,
      equalTo: '#password'
    }
  },
  messages: {
    name: {
      required: "Your name is required"
    },
    email: {
      email: "Please enter a valid email",
      required: "Please enter an email"
    },
    password: {
      minlength: "Your password must have more than 5 characters",
      required: "Please enter a password"
    },
    password_confirm: {
      minlength: "Your password must have more than 5 characters",
      required: "Please enter the password confirmation",
      equalTo: 'Your passwords do not match'
    }
  }
})

form_signup = $('#signup')

$('#signup').submit((e)->
  e.preventDefault()
  if $('#signup').valid()
    $.auth.emailSignUp(
      name: form_signup.find('#name').val()
      email: form_signup.find('#email').val()
      password: form_signup.find('#password').val()
      password_confirmation: form_signup.find('#passwod_confirm').val()
    ).then((resp) ->
      console.log "we have success"
      $.ajax
        url: Routes.api_v1_members_url()
        type: 'post'
        dataType: 'json'
        data: { website_member: { token: gon.token, email: form_signup.find('#email').val() } }
        success: (data) ->
          location.href = '/errors'
    ).fail ((resp) ->
      EpicLogger.addAlert(resp.data.errors.full_messages)
      console.log "we failed"
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

