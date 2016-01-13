directive = {
  websites:{
    website_row:
      id: (params)->
        "website_" + this.id
    delete_website:
      href: (params) ->
        Routes.api_v1_website_path(this.id, {format: 'js'})
  }
  events_dsn:
    html: ()->
      '<span class="line">https://' + this.app_key + ':' + this.app_id + '@test-sentry89.herokuapp.com/' + this.id + '</span>'
  public_dsn:
    html: ()->
      '<span class="line">https://' + this.app_key + '@test-sentry89.herokuapp.com/' + this.id + '</span>'
  js_client_configuration:
    html: ()->
      "&lt;script&gt;<br />Raven.config('https://"+this.app_key+"@test-sentry89.herokuapp.com/"+this.id+"', {<br />
      # we highly recommend restricting exceptions to a domain in order to filter out clutter<br />
      whitelistUrls: [/example\.com/]<br />}).install();<br />&lt;/script&gt;"
  node_client_configuration:
    html: ()->
      "var epiclogger = require('epiclogger');<br /><br />var client = new epiclogger.Client('https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"');"
  express_client_configuration:
    html: ()->
      "var app = require('express').createServer();<br /><br />app.error(epiclogger.middleware.express('https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"'));"
  connect_client_configuration:
    html: ()->
      "connect(<br />connect.bodyParser(),<br />connect.cookieParser(),<br />mainHandler,<br />raven.middleware.connect('https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"'),<br />).listen(3000);"
  ruby_client_configuration:
    html: ()->
      "require 'raven'<br /><br />Raven.configure do |config|<br />  config.dsn = 'https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"'<br />end"
  sinatra_client_configuration:
    html: ()->
      "require 'sinatra'<br />require 'raven'<br /><br />Raven.configure do |config|<br />  config.dsn = 'https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"'<br />end<br /><br />use Raven::Rack<br /><br />get '/' do<br />  1 / 0<br />end"
  python_client_configuration:
    html: ()->
      "from raven import Client<br /><br />client = Client('https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"')"
  python_test_command:
    html: ()->
      "raven test https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+""
  django_client_configuration:
    html: ()->
      "# Set your DSN value<br />RAVEN_CONFIG = {<br />    'dsn': 'https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"',<br />}<br /><br /># Add raven to the list of installed apps<br />INSTALLED_APPS = INSTALLED_APPS + (<br />    # ...<br />    'raven.contrib.django.raven_compat',<br />)"
  flask_client_configuration:
    html: ()->
      "from raven.contrib.flask import Sentry<br /><br />app.config['SENTRY_DSN'] = 'https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"'<br />sentry = Sentry(app)"
  tornado_client_configuration:
    html: ()->
      'import tornado.web<br />from raven.contrib.tornado import AsyncSentryClient<br /><br />class MainHandler(tornado.web.RequestHandler):<br />    def get(self):<br />        self.write("Hello, world")<br /><br />application = tornado.web.Application([<br />    (r"/", MainHandler),<br />])<br />application.sentry_client = AsyncSentryClient(<br />    "https://'+this.app_key+":"+this.app_id+'@test-sentry89.herokuapp.com/'+this.id+'"<br />)'
  ios_client_configuration:
    html: ()->
      '- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {<br />    // Configure the Sentry client<br />    [RavenClient clientWithDSN:@"https://'+this.app_key+':'+this.app_id+'@test-sentry89.herokuapp.com/'+this.id+'"];<br /><br />    // Install the global error handler<br />    [[RavenClient sharedClient] setupExceptionHandler];<br /><br />    return YES;<br />}'
  php_client_configuration:
    html: ()->
      "$client = new Raven_Client('https://"+this.app_key+":"+this.app_id+"@test-sentry89.herokuapp.com/"+this.id+"');"
  java_client_configuration:
    html: ()->
      'import net.kencochrane.raven.Raven;<br />import net.kencochrane.raven.Raven;<br />import net.kencochrane.raven.event.EventBuilder;<br />import net.kencochrane.raven.event.interfaces.ExceptionInterface;<br /><br />public class Example {<br />    public static void main(String[] args) {<br />        String rawDsn = "https://'+this.app_key+":"+this.app_id+'@test-sentry89.herokuapp.com/'+this.id+'";<br />        Raven raven = RavenFactory.ravenInstance(new Dsn(rawDsn));<br /><br />        // record a simple message<br />        EventBuilder eventBuilder = new EventBuilder()<br />                        .setMessage("Hello from Raven!")<br />                        .setLevel(Event.Level.ERROR)<br />                        .setLogger(MyClass.class.getName())<br />                        .addSentryInterface(new ExceptionInterface(e));<br />                        <br />        raven.runBuilderHelpers(eventBuilder); // Optional<br />        raven.sendEvent(eventBuilder.build());<br />    }<br />}'
  java_util_logging_client_configuration:
    html: ()->
      'level=ERROR<br />handlers=net.kencochrane.raven.jul.SentryHandler<br />net.kencochrane.raven.jul.SentryHandler.dsn=https://'+this.app_key+':'+this.app_id+'@test-sentry89.herokuapp.com/'+this.id+''
  log4j_client_configuration:
    html: ()->
      'log4j.rootLogger=DEBUG, SentryAppender<br />log4j.appender.SentryAppender=net.kencochrane.raven.log4j.SentryAppender<br />log4j.appender.SentryAppender.dsn=https://'+this.app_key+':'+this.app_id+'@test-sentry89.herokuapp.com/'+this.id+'<br />level=ERROR'
  log4j2_client_configuration:
    html: ()->
      '&lt;?xml version="1.0" encoding="UTF-8"?&gt;<br />&lt;configuration status="warn" packages="org.apache.logging.log4j.core,net.kencochrane.raven.log4j2"&gt;<br />    &lt;appenders&gt;<br />        &lt;Raven name="Sentry"&gt;<br />            &lt;dsn&gt;<br />                https://'+this.app_key+":"+this.app_id+'@test-sentry89.herokuapp.com/'+this.id+'<br />            &lt;/dsn&gt;<br />        &lt;/Raven&gt;<br />    &lt;/appenders&gt;<br /><br />    &lt;loggers&gt;<br />        &lt;root level="error"&gt;<br />            &lt;appender-ref ref="Sentry"/&gt;<br />        &lt;/root&gt;<br />    &lt;/loggers&gt;<br />&lt;/configuration&gt;'
  logback_client_configuration:
    html: ()->
      '&lt;configuration&gt;<br />    &lt;appender name="Sentry" class="net.kencochrane.raven.logback.SentryAppender"&gt;<br />        &lt;dsn&gt;<br />            https://'+this.app_key+':'+this.app_id+'@test-sentry89.herokuapp.com/'+this.id+'<br />        &lt;/dsn&gt;<br />    &lt;/appender&gt;<br /><br />    &lt;root level="error"&gt;<br />        &lt;appender-ref ref="Sentry"/&gt;<br />    &lt;/root&gt;<br />&lt;/configuration&gt;'
}
changeButtonValue = () ->
  $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
    if data.websites.length > 0
      $('#custom-button').text('Go back')
      $('#custom-button').removeAttr('onclick')
      $('#custom-button').attr('href', '/websites')

PubSub.subscribe('assigned.website', (ev, website)->
  console.log gon.action
  switch gon.action
    when "new"
      changeButtonValue()
      $('#myModal').modal('show')
      $.getJSON Routes.api_v1_website_path(website.id), (data) ->
        $('#current-website').render data, directive
        $('.tabs').hide()
    when "index"
      $.getJSON Routes.api_v1_websites_url(), {member_id: $.auth.user.id}, (data) ->
        $('#websites-container').render data, directive
        console.log 'data loaded'

)

goToStep = (n) ->
  if n != 0
    $('.stepwizard-row a').removeClass('btn-primary')
    $('.stepwizard-row a').addClass('btn-default')
    $('.tab'+n).attr('disabled', false)
    $('.stepwizard a[href="#step-' + n + '"]').tab 'show'
    $('.stepwizard-row a[href="#step-' + n + '"]').removeClass 'btn-default'
    $('.stepwizard-row a[href="#step-' + n + '"]').addClass 'btn-primary'
  return

$('li').on 'click', (e) ->
  $('.tabs').hide()
  $(e.target).tab('show')
  $($(e.target).attr('href')).show()

$('.tab').hide()
# $('.tab2, .tab3').addClass('disabled')

$('#back, .tab2').on 'click', () ->
  $('.tab').hide()
  $('.tabs').hide()
  $('.tab3').addClass('disabled')
  goToStep(2)

$('#finish').on 'click', () ->
  location.href = '/errors'

$('#platform a, .tab3').on 'click', (e) ->
  $('.tab').hide()
  $('#'+this.name).show()
  goToStep(3)
  $('.tab3').removeClass('disabled')


$('#addWebsite').submit (e) ->
  e.preventDefault()
  $.ajax
    url: Routes.api_v1_websites_url()
    type: 'post'
    dataType: 'json'
    data: $('#addWebsite').serialize()
    success: (data) ->
      EpicLogger.setMemberDetails(data.id)
      goToStep(2)
      $('.tab1').addClass('disabled')
      $('.tab2').removeClass('disabled')
    error: (error) ->
      sweetAlert("Error", "Website exists!", "error") if error.status == 401
  return
return