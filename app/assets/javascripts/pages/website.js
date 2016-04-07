$(function () {
	$('.tabs').hide();
  $('#'+gon.platform).show();
  $('.tab li').click(function(e){
    e.stopPropagation();
    $('.tabs').hide();
    $(this).tab('show');
    $($(this).children().attr('href')).show()
  });
});
