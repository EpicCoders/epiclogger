PubSub.subscribe('assigned.website', (ev, website)->
  switch gon.action
    when "index"
      hideIndexHtml()
      $('#client-information, #client-platforms, #client-frameworks').show()
      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data

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

      $('#platforms-tabs').on 'click', (e) ->
        target = $(e.target.closest("li"))
        $('#platforms-tabs li').removeClass('active')
        target.addClass('active')
        manipulateInstallationsIndex(target)

      $('#img-platforms').on 'click', (e) ->
        manipulateInstallationsIndex($(e.target).parent())
        $('#platforms-tabs li').removeClass('active')


hideIndexHtml = () ->
  $('#current-site, #client-information, #client-platforms, #client-frameworks, #javascript, #php, #python, #ruby, #java, #node-js, #ios').hide()

manipulateInstallationsIndex = (target) ->
  hideIndexHtml()
  $('#current-site').show()
  if target.attr('name') == 'javascript'
    $('#javascript').show()
  else if target.attr('name') == 'python'
    $('#python').show()
  else if target.attr('name') == 'php'
    $('#php').show()
  else if target.attr('name') == 'ruby'
    $('#ruby').show()
  else if target.attr('name') == 'java'
    $('#java').show()
  else if target.attr('name') == 'node.js'
    $('#node-js').show()
  else if target.attr('name') == 'ios'
    $('#ios').show()
  else if target.attr('name') == 'all platforms'
    $('#current-site').hide()
    $('#client-information, #client-platforms, #client-frameworks').show()

)