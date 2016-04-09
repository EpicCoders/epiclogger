$(function () {
	$('.tabs').hide();
  $('.tab li').removeClass('active')
  $("a[name='"+gon.platform+"']").parent().addClass('active')
  $('#'+gon.platform).show();
  $('.tab li').click(function(e){
    e.stopPropagation();
    $('.tabs').hide();
    $(this).tab('show');
    $($(this).children().attr('href')).show()
  });
});
