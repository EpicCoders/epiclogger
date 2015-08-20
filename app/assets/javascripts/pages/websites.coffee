# directive = {
#   url: {
#   	href: (params) ->
#   		Routes.website_path(this.id)
# 	}
# }
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
	  	EpicLogger.setMemberDetails()
	  	window.location = "/installations/show"
	return
return

# $('#get-id').on 'click', (e)->
# 	$(this).closest('tr').attr('id')
# 	console.log 'id is here' + $(this).closest('tr').attr('id')


$('a.delete-website').click ->
  website_id = $(this).closest('tr').attr('id')
  $.post '/api/v1/websites/' + website_id, { _method: 'delete' }, null, 'script'
  false