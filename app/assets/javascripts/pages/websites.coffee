directive = {
  websites:{
    website_row:
      id: (params)->
        "website_" + this.id
    delete_website:
      href: (params) ->
        id = this.id
        Routes.api_v1_websites_path({id})
  }
}

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        console.log 'data loaded'
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
	  	EpicLogger.setMemberDetails()
	  	window.location = "/installations/show"
	return
return
