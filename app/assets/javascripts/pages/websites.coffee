PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data
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
	  	EpicLogger.pickWebsite(undefined, data.id)
	  	window.location = "/installations/show"
	return
return

# $('a.delete').click ->
#   console.log 'getting website id'
#   website_id = $(this).attr 'id'
#   # we just need to add the key/value pair for the DELETE method
#   # as the second argument to the JQuery $.post() call
#   $.post Routes.api_v1_websites_url(website_id), { _method: 'delete' }, null, 'script'
#   false