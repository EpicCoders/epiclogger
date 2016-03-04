# important don't add $ -> here when using PubSub as the event will be assigned every time
console.log "users loaded"
PubSub.subscribe('assigned.website', (ev, website)->
  return unless gon.controller == 'users'
  console.log 'getting users'
  $.getJSON('/api/v1/users', {website_id: website.id}, (data)->
    $('#userscontainer').render data
  )
)
