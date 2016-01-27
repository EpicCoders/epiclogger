PubSub.subscribe('assigned.website', (ev, website)->
  directive = {
    website_members:{
      role:
        html: ()->
          "#{this.role}"
      member_row:
        id: (params)->
          "member_" + this.id
      delete_member:
        href: (params) ->
          Routes.api_v1_website_member_path( this.id, {format: 'js', website_id: this.website_id})
    }
  }

  console.log gon.action
  switch gon.action
    when "index"
      $.getJSON Routes.api_v1_website_members_url(), { website_id: website.id }, (data) ->
        $('#members-container').render data, directive

)