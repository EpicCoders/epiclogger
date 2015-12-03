window.Installations = (->
  getCurrentSite: ->
    PubSub.subscribe('assigned.website', (ev, website)->
      switch gon.action
        when "index"
          $('#platforms-tabs').on 'click', (e) ->
            $('#platforms-tabs li').removeClass('active')
            $(e.target.closest("li")).addClass('active')

          $('#configuration-tabs').on 'click', (e) ->
            target = $(e.target.closest("li"))
            e.preventDefault()
            $('#configuration-tabs li').removeClass('active')

            if target.attr('name') == 'details'
              $('#client-configuration').hide()
            else if target.attr('name') == 'integrations'
              $('#client-configuration').hide()
            else if target.attr('name') == 'client configuration'
              $('#client-configuration').show()
            target.addClass('active')

        when "show"
          $.getJSON Routes.api_v1_website_path(website.id), (data) ->
            $('#current-website').render data
            return data
            console.log 'website loaded'
    )
)(jQuery)
Installations.getCurrentSite()