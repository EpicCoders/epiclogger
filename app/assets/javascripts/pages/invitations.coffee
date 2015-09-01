PubSub.subscribe('assigned.website', (ev, website)->
  $('#addMember').submit (e) ->
    e.preventDefault()
    $.ajax
      url: Routes.api_v1_invitations_url()
      type: 'post'
      dataType: 'json'
      data: { member: { email: $('#addMember').find('#getEmail').val(), website_id: website.id } }
      success: (data) ->
        window.location = "/members"
    return
  return
)