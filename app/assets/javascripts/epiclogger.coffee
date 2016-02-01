window.EpicLogger = (->
  pickedWebsite = undefined
  memberWebsites = undefined
  errorCount = undefined

  doLoad: ->
    $('.loading').addClass('j-cloak')

  doneLoad: ->
    $('.loading').removeClass('j-cloak')
    $('.main-wrapper').css('display','inline')

  setSidebar: ->
    if (gon.controller != "errors" and gon.action != "show") or (gon.controller == "errors" and gon.action == "index")
      $('.toggle-left-sidebar').unbind('click').on 'click', () ->
        if $(window).width() < 1170
          $('.main-container').toggleClass('cbp-spcontent-pushed-right')
          $('.cbp-spmenu-vertical').toggleClass('cbp-spmenu-vertical-pushed-right')
      EpicLogger.bindResize()
      $('#pick_website').hide()
      $('.website-container').find('.add-new, .border').slideUp 80
      $('.picked-website, #websites-sidebar').on 'click', ->
        $('.website-container').find('.add-new, .border').toggle()
        $('#websites-sidebar').toggleClass('show-websites')

  setUpSidebar: (width) ->
    if width >= 1170
      #decrease content max-width with the sidebars width since its being pushed to the right
      $('.cbp-spcontent').css('max-width','calc(100% - 230px)')

      #push content to the right
      $('.main-container').addClass('cbp-spcontent-pushed-right')
      $('.cbp-spmenu-vertical').addClass('cbp-spmenu-vertical-pushed-right')

      #remove mobile classes when its being resized to a higher width
      $('.main-container').removeClass('cbp-spcontent-full-width')
      $('.cbp-spmenu-vertical').removeClass('cbp-spmenu-vertical-hidden')

      $('.toggle-left-sidebar').hide()
    else
      #content no longer pushed to the right as a default
      $('.cbp-spcontent').css('max-width','none')

      #remove classes if its being resized to a lower width
      $('.main-container').removeClass('cbp-spcontent-pushed-right')
      $('.cbp-spmenu-vertical').removeClass('cbp-spmenu-vertical-pushed-right')

      #add classes for mobile version
      $('.main-container').addClass('cbp-spcontent-full-width')
      $('.cbp-spmenu-vertical').addClass('cbp-spmenu-vertical-hidden')

      $('.toggle-left-sidebar').show()

  getErrorCount: (website) ->
    $.getJSON Routes.api_v1_errors_path(), { website_id: website.id}, (data) ->
      $('.error-count-badge').remove();
      if data.groups.length > 0
        $('#errornav').append('<span class="error-count-badge">' + data.groups.length + '</span>')

  bindResize: ->
    $(window).unbind().on 'resize', (e) ->
      EpicLogger.setUpSidebar($(window).width())
    $(document).ready ->
      if (gon.controller != "errors" and gon.action != "show") or (gon.controller == "errors" and gon.action == "index")
        EpicLogger.setUpSidebar($(window).width())

  logout: ->
    $.removeCookie('pickedWebsite', {path: '/'})
    $.auth.signOut()

  hideFormUl: ->
    $('ul[role="menu"]').hide()
    $('#steps-uid-0-t-2').parent().removeClass('done').addClass('disabled')

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

      if pickedWebsite == undefined
        $('.picked-website').text("EpicLogger")
        $('.picked-website').unbind()
      else
        if pickedWebsite.title.length > 10
          pickedWebsite.title = pickedWebsite.title.substring(0,8 ) + "..."
        $('.picked-website').text(pickedWebsite.title).append("&nbsp&nbsp&nbsp<i class='fa fa-angle-down'>") # render the current website

      $.cookie('pickedWebsite', pickedWebsite.id, { path: '/' }) # save the website id in the cookies
      PubSub.publishSync('assigned.website', pickedWebsite)
      EpicLogger.getErrorCount(pickedWebsite)
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
          html: ->
            if this.title.length > 16
              return this.title.substring(0,13) + "..."
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
