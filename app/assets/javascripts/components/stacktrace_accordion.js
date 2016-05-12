(function($) {
 "use strict"
  var iconOpen = 'fa fa-minus',
      iconClose = 'fa fa-plus';

  $(document).on('show.bs.collapse hide.bs.collapse', '.accordion', function (e) {
      var $target = $(e.target)
        $target.siblings('.accordion-heading')
        .find('em').toggleClass(iconOpen + ' ' + iconClose);
        if(e.type == 'show')
            $target.prev('.accordion-heading').find('.accordion-toggle').addClass('active');
        if(e.type == 'hide')
            $(this).find('.accordion-toggle').not($target).removeClass('active');
  });
})(jQuery);