# important don't add $ -> here when using PubSub as the event will be assigned every time
console.log "errors loaded"
directive = {
  errors:{
    warning: {
      href: (params) ->
        Routes.error_path(this.id)
    }
    occurrences:
      html: () ->
        "#{this.occurrences} occurrences"
    users_count:
      html: ()->
        "#{this.users_count} users subscribed"
    last_occurrence:
      html: ()->
        moment(this.last_occurrence).calendar()
  },
  created_at:
    html: ()->
      moment(this.created_at).calendar()
  last_occurrence:
    html: ()->
      moment(this.last_occurrence).calendar()
  subscribers_count:
    html: ()->
      "Send an update to #{this.subscribers_count} subscribers"
}
PubSub.subscribe('assigned.website', (ev, website)->
  console.log 'getting errors'

  switch gon.action
    when "index"
      $.getJSON '/api/v1/errors', { website_id: website.id }, (data) ->
        $('#errorscontainer').render data, directive
    when 'show'
      $.getJSON '/api/v1/errors/' + gon.error_id, { website_id: website.id }, (data) ->
        $('#errordetails').render data, directive
)

$('#solve').on 'click', (e)->
  e.preventDefault();
  $.ajax
    data: {error: {status: 'resolved'}}
    url: Routes.api_v1_error_url(gon.error_id)
    type: 'PUT'
    success: (result)->
      alert 'Status updated'
  return