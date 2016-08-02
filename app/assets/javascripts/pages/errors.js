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

  $( ".sidebar-filters button" ).click(function() {
    uri = window.location.href
    var re = new RegExp("([?&])search=[^&#]*", "i");
    if (re.test(uri)) {
      uri = uri.replace(re, "$1search=" + $('#search-input').val());
    } else {
      var separator = /\?/.test(uri) ? "&" : "?";
      uri = uri + separator + "search=" + $('#search-input').val();
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