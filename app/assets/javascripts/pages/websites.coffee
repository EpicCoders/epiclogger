
PubSub.subscribe('auth.validation.success', (ev, member)->
  console.log 'Getting Websites'
  $.getJSON('/api/v1/websites', {member: member.id}, (data)->
  	$.each data, (i, websites) ->
  		$.each websites, (index, website) ->
    		$('#get-websites').append '<p>' + website.domain + '</p>'
  )
)

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
	  	window.location = "/websites"
	return
return