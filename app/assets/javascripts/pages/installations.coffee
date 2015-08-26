PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "show"
      $.getJSON Routes.api_v1_websites_url() + '/' + website.id, (data) ->
        $('#current-website').render data
        console.log 'website loaded'
)