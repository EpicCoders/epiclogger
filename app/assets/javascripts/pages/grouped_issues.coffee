PubSub.subscribe('assigned.website', (ev, website)->
  $.getJSON Routes.api_v1_errors_path(), { website_id: website_id }, (data) ->
    $('.list_errors').render data
  $('#notify').on 'click', () ->
    dataString = $('#notifysub').val()
    if dataString.length == 0
      sweetAlert("Noty", "You can't submit a blank form!", "warning")
      return false
    else
      $.ajax
        url: Routes.notify_subscribers_api_v1_error_url(gon.error_id)
        type: 'POST'
        data: {website_id: website.id, group_id: gon.error_id, message: dataString}
        success: (data) ->
          swal("Success", "Message sent", "success")
          $('#notifysub').val('')
          return false
)