PubSub.subscribe('assigned.website', (ev, website)->
	switch gon.action
		when "show"
			$.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
				$('#current-website').render data
				debugger;
				console.log 'website loaded'
)