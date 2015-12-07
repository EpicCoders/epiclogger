window.EpicLogger = (->
  pickedWebsite = undefined
  memberWebsites = undefined

  setSidebar: ->
    if gon.controller == "errors" and gon.action == "show"
      $('.cbp-spmenu-vertical').toggleClass('cbp-spmenu-sidebar-hide-left')
      $('.main-container').toggleClass('cbp-spcontent-mobile')
    else
      $('.main-container').toggleClass('cbp-spcontent-regular-page')
    $('.toggle-left-sidebar').hide() unless $('.main-container').hasClass('cbp-spcontent-mobile')
    
    $('.toggle-left-sidebar').on 'click', () ->
      $('.cbp-spmenu-vertical').toggleClass('cbp-spmenu-sidebar-hide-left')
      $('.main-container').toggleClass('cbp-spcontent-mobile')


  logout: ->
    $.removeCookie('pickedWebsite', {path: '/'})
    $.auth.signOut()

  doLoad: ->
    $('.loading').addClass('j-cloak')

  doneLoad: ->
    $('.loading').removeClass('j-cloak')

  pickWebsite: (el, website_id)->
    # we check to see if we are calling this from a link call
    $('#navLink').show()
    if memberWebsites != null
      $('#navLink').hide()
      if el!=undefined
        website_id = $(el).data('id')
      # let's find the website_id in the websites from the database
      for website in memberWebsites
        if website.id==parseInt(website_id)
          pickedWebsite = website

      pickedWebsite = memberWebsites[0] if pickedWebsite == undefined
      console.log 'assigned website'
      $('.picked-website').render pickedWebsite # render the current website
      $.cookie('pickedWebsite', pickedWebsite.id, { path: '/' }) # save the website id in the cookies
      console.log pickedWebsite
      PubSub.publishSync('assigned.website', pickedWebsite)
    return pickedWebsite
    false

  setMemberDetails: (picked_id)->
    $.getJSON('/api/v1/websites', (data)->
      memberWebsites = data.websites
      if memberWebsites.length == 0
        $.removeCookie('pickedWebsite', { path: '/' })
        if window.location.pathname != "/websites/new"
          EpicLogger.doLoad()
          window.location = "/websites/new"
      if picked_id != undefined
        EpicLogger.pickWebsite(undefined, picked_id)
      else
        if $.cookie('pickedWebsite')!=undefined
          EpicLogger.pickWebsite(undefined, $.cookie('pickedWebsite'))
        if window.location.pathname != "/websites/new"
          EpicLogger.pickWebsite(undefined, data.websites[0].id)
      PubSub.publish('details.websites', data );

      directive = {
        title: {
          'data-id': ()->
            this.id
        }
      }
      $('#websites-sidebar').render data.websites, directive
    )

  renderMember: ->
    userDirectives = {
      name: {
        html: ->
          "Hello, #{this.name}"
      }
    }
    $helpfulLink = $('.helpful-link')
    $helpfulLink.attr('data-helpful-email', $.auth.user.email)
    $helpfulLink.attr('data-helpful-name', $.auth.user.name)
    $('.user-sidebar').render $.auth.user, userDirectives

  isPage: (page)->
    current_path = window.location.pathname
    return true if current_path == "/#{page}"
    return false

  # -------------------------------------
  # some simple method that adds error message
  # -------------------------------------
  addAlert: (msg,type='error')->
    if $.isPlainObject(msg)
      html = "<ul>"
      for index,elem of msg
        html+= "<li>#{index.replace(/_/g,' ')}: #{elem[0]}</li>"
      html+="</ul>"
      msg = html
    alert(msg)

  authInitialization: ->
    $.auth.configure({
      apiUrl: '/api/v1'
    })
    $(document).on('ajax:beforeSend', [$.rails.linkClickSelector,$.rails.buttonClickSelector].join(','), (e, xhr, settings) ->
      $.auth.appendAuthHeaders(xhr, settings)
    )
    PubSub.subscribe('auth', (ev, msg)->
      if ev == 'auth.validation.success'
        EpicLogger.doneLoad()
        EpicLogger.setMemberDetails()
        EpicLogger.renderMember()
      else if ev == 'auth.validation.error'
        current_path = window.location.pathname
        console.log current_path
        if current_path not in ['/login', '/signup', '/']
          window.location.href = '/login'
      else if ev == 'auth.signOut.success'
        window.location.href = '/login'
      else if ev == 'auth.oAuthSignIn.success' or ev == 'auth.signIn.success'
        window.location.href = '/errors'
      console.log ev
      console.log msg
      # console.log $.auth.user
    )
    # $('.user').render $.auth.user

  initMain: ->
    $(document).on("page:before-change", ->
      PubSub.clearAllSubscriptions()
    )
    $(document).ready ->
      EpicLogger.setSidebar()
      EpicLogger.authInitialization()

      return
    return

)(jQuery)

EpicLogger.initMain()
