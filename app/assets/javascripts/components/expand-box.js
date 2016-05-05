$(function () {
  var $el, $ps, $up, totalHeight;

  $(".expand-box .btn").click(function() {
    totalHeight = 30
    defaultHeight = 700
    console.log('dada');
    $el = $(this);
    $p  = $el.parent();
    $up = $p.parent();
    $ps = $up.find("div");

    // measure how tall inside should be by adding together heights of all inside paragraphs (except read-more paragraph)
    $ps.each(function() {
      totalHeight += $(this).outerHeight();
    });

    // if the stacktrace is too big we should add a scrollbar
    if(totalHeight < defaultHeight){
      defaultHeight = totalHeight      
    }
    else{
      $up.css({ "overflow": "auto" })      
    }

    $up
      .css({
        // Set height to prevent instant jumpdown when max height is removed
        "height": $up.height(),
        "max-height": defaultHeight
      })
      .animate({
        "height": defaultHeight
      });

    // fade out read-more
    $p.fadeOut();

    // prevent jump-down
    return false;
  });
});