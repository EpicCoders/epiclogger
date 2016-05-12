//= require_tree ./pages
//= require_tree ./components

ready = function() {
  hljs.initHighlighting.called = false;
  hljs.initHighlighting();
  $("#menu-toggle").click(function(e) {
    e.preventDefault();
    $("#wrapper").toggleClass("toggled");
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);
