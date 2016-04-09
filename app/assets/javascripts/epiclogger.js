//= require_tree ./pages
//= require_tree ./components

$( document ).ready(function() {
  $("#menu-toggle").click(function(e) {
    e.preventDefault();
    $("#wrapper").toggleClass("toggled");
  });
});
