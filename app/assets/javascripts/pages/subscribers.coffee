$('#addSubscriber').submit (e) ->
  e.preventDefault()
  $.ajax
    url: Routes.api_v1_subscribers_url()
    type: 'post'
    dataType: 'json'
    console.log 'ceva'
    website = Installations.getCurrentSite()
    data: { subscriber: { subscriber_email: $('#addSubscriber').find('#getEmail').val(), webstie_id: website.id  } }
    success: (data) ->
      window.location = "/members"
  return
return