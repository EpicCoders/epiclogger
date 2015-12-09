window.EpicLogger = (->
  pickedWebsite = undefined
  memberWebsites = undefined

  doLoad: ->
    $('.loading').addClass('j-cloak')

  doneLoad: ->
    $('.loading').removeClass('j-cloak')
    $('.main-wrapper').css('display','inline')
  
  setSidebar: ->
    if (gon.controller != "errors" and gon.action != "show") or (gon.controller == "errors" and gon.action == "index")
      $('.toggle-left-sidebar').unbind('click').on 'click', () ->
        $('.toggle-left-sidebar').toggleClass('toggle-left-sidebar-open')
        if $(window).width() < 1170
          $('.main-container').toggleClass('cbp-spcontent-pushed-right')
          $('.cbp-spmenu-vertical').toggleClass('cbp-spmenu-vertical-pushed-right')
      EpicLogger.bindResize()
    $('#pick_website').hover (->
      $('#pick_website .sub-menu').addClass 'open-menu'
      $('#pick_website .fa-angle-right').addClass('fa-angle-down').removeClass('fa-angle-right')
      return
    ), ->
      $('#pick_website .sub-menu').removeClass 'open-menu'
      $('#pick_website .fa-angle-down').removeClass('fa-angle-down').addClass('fa-angle-right')
      return
    $('#user_options').hover (->
      $('#user_options .sub-menu').addClass 'open-menu'
      return
    ), ->
      $('#user_options .sub-menu').removeClass 'open-menu'
      return

  setUpSidebar: (width) ->
    if width >= 1170
      $('.cbp-spcontent').css('max-width','calc(100% - 50px)')
      $('.main-container').addClass('cbp-spcontent-pushed-right')
      $('.cbp-spmenu-vertical').addClass('cbp-spmenu-vertical-pushed-right')
      $('.main-container').removeClass('cbp-spcontent-full-width')
      $('.cbp-spmenu-vertical').removeClass('cbp-spmenu-vertical-hidden')
    else
      $('.cbp-spcontent').css('max-width','none')
      $('.main-container').removeClass('cbp-spcontent-pushed-right')
      $('.cbp-spmenu-vertical').removeClass('cbp-spmenu-vertical-pushed-right')
      $('.main-container').addClass('cbp-spcontent-full-width')
      $('.cbp-spmenu-vertical').addClass('cbp-spmenu-vertical-hidden')

  bindResize: ->
    $(window).unbind().on 'resize', (e) ->
      EpicLogger.setUpSidebar($(window).width())
    $(document).ready ->
      if (gon.controller != "errors" and gon.action != "show") or (gon.controller == "errors" and gon.action == "index")
        EpicLogger.setUpSidebar($(window).width())

  logout: ->
    $.removeCookie('pickedWebsite', {path: '/'})
    $.auth.signOut()


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
      $('.picked-website').text(pickedWebsite.title).append("&nbsp&nbsp&nbsp<i class='fa fa-angle-right'>") # render the current website
      $.cookie('pickedWebsite', pickedWebsite.id, { path: '/' }) # save the website id in the cookies
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
          "#{this.name}"
      }
    }
    $helpfulLink = $('.helpful-link')
    $helpfulLink.attr('data-helpful-email', $.auth.user.email)
    $helpfulLink.attr('data-helpful-name', $.auth.user.name)
    $('#user_options').render $.auth.user, userDirectives

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
        EpicLogger.setMemberDetails()
        EpicLogger.renderMember()
        EpicLogger.doneLoad()
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
