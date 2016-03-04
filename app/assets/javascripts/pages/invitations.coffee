PubSub.subscribe('assigned.website', (ev, website)->
  return unless gon.controller == 'invitations'
  $('#addMember').submit (e) ->
    e.preventDefault()
    $.ajax
      url: Routes.api_v1_invitations_url()
      type: 'post'
      dataType: 'json'
      data: { member: { email: $('#addMember').find('#getEmail').val() }, website_id: website.id }
      success: (data) ->
        alert 'Invitation sent'
        window.location = "/members"
    return
  return
)