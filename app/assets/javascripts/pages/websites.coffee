console.log "errors here"
$('#addWebsite').submit (e) ->
  e.preventDefault()
  $.ajax
	  url: Routes.api_v1_websites_url()
	  type: 'post'
	  dataType: 'json'
	  data: { website: { domain: $('#addWebsite').find('#domain').val(), title: $('#addWebsite').find('#title').val() } }
	  success: (data) ->
	  	alert ' Mesaj ca s-a adaugat ba'
	  	window.location = "/installations"
	return
return

$.getJSON('/api/v1/websites', (data)->
  memberWebsites = data.websites

  directive = {
    title: {
      'data-id': ()->
        this.id
    }
  }
  $('#websites').render data.websites, directive
)