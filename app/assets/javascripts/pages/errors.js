function addKeysToUrl(uri, key, value) {
  var re = new RegExp("([?&])"+ key +"=[^&#]*", "i");
  if (re.test(uri)) {
    uri = uri.replace(re, "$1"+ key +"=" + value);
  } else {
    var separator = /\?/.test(uri) ? "&" : "?";
    uri = uri + separator + key +"=" + value;
  }
  return uri
}

function removeSearchParameter(){
  uri = window.location.href
  if (uri.indexOf('search') > -1){
    value = new RegExp('[\?&]' + 'search' + '=([^&#]*)').exec(uri)[1]
    keyValue = 'search='+value
    var re = new RegExp("([&\?]"+ keyValue + "*$|" + keyValue + "&|[?&]" + keyValue + "(?=#))", "i");
    uri = uri.replace(re, '')
  }
  return uri
}
$(function () {
  //actions to the sidebar when resolving errors
  var removeFromSidebar = function(e){
    var id, element;
    id = $('.error-content').attr('data-id');
    e.stopPropagation();
    element = $(".errors-sidebar-elements[data-id='"+id+"']");
    if(element){
      $(element).fadeOut(500, function() { $(this).remove(); });
    }
  }
  $('#resolve-button').click(removeFromSidebar);
  $('#unresolve-button').click(removeFromSidebar);

  $('#datetimepicker-from').datetimepicker();
  $('#datetimepicker-until').datetimepicker({
    useCurrent: false //Important! See issue #1075
  });
  $("#datetimepickesearchr-from").on("dp.change", function (e) {
    $('#datetimepicker-until').data("DateTimePicker").minDate(e.date);
  });
  $("#datetimepicker-until").on("dp.change", function (e) {
    $('#datetimepicker-from').data("DateTimePicker").maxDate(e.date);
  });

  $( ".sidebar-filters button" ).click(function() {
    uri = window.location.href
    if (this.id == 'search-button'){
      uri = addKeysToUrl(uri, 'search', $('#search-input').val())
    } else {
      uri = removeSearchParameter() //removing the search parameter simplifies the controller code
      if ($('#env-filter').val() != 'all') uri = addKeysToUrl(uri, 'env', $('#env-filter').val())
      if (!isNaN(Date.parse($('#datetimepicker-from input').val()))) uri = addKeysToUrl(uri, 'from', $('#datetimepicker-from input').val())
      if (!isNaN(Date.parse($('#datetimepicker-until input').val()))) uri = addKeysToUrl(uri, 'until', $('#datetimepicker-until input').val())
      if ($("#status-filter input:checked").length > 0) uri = addKeysToUrl(uri, 'status', $("#status-filter input:checked")[0].value)
    }
    window.location.href = uri;
  });


  $('#resolve-form').submit(function(){
    var checked;
    checked = $('.list-group input:checked');
    if(checked.length > 0){
      checked.each(function() {
        $(this).closest('.errors-sidebar-elements').fadeOut(500, function() { $(this).closest('.errors-sidebar-elements').remove(); });
      });
    }
    else{
      alert("Please make a selection before submitting!")
      return false
    }
  });
});