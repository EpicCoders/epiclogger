$(function () {
  hljs.initHighlighting.called = false;
  hljs.configure({
    tabReplace: '  ' // 2 spaces
  })
  hljs.initHighlighting();
  $("#menu-toggle").click(function(e) {
    e.preventDefault();
    $("#wrapper").toggleClass("toggled");
  });
});