PubSub.subscribe('assigned.website', (ev, website)->
	switch gon.action
		when "show"
			$.getJSON '/api/v1/websites/' + website.id, (data) ->
				$('#current-website').render data
				console.log 'website loaded'
)