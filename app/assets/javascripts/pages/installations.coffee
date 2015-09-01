window.Installations = (->
  getCurrentSite: ->
    PubSub.subscribe('assigned.website', (ev, website)->
      switch gon.action
        when "show"
          $.getJSON Routes.api_v1_website_path(website.id), (data) ->
            $('#current-website').render data
            return data
            console.log 'website loaded'
    )
)(jQuery)
Installations.getCurrentSite()