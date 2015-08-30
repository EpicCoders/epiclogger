PubSub.subscribe('assigned.website', (ev, website)->
  $('#addSubscriber').submit (e) ->
    e.preventDefault()
    $.ajax
      url: Routes.api_v1_subscribers_url()
      type: 'post'
      dataType: 'json'
      data: { subscriber: { email: $('#addSubscriber').find('#getEmail').val(), website: EpicLogger.pickWebsite() } }
      success: (data) ->
        window.location = "/members"
    return
  return
)