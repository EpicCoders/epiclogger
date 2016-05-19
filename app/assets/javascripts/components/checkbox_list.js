$(function () {
  /* toggle all checkboxes in group */
  $('.all').click(function(e){
    e.stopPropagation();
    var $this = $(this);
    if($this.is(":checked")) {
      $('.list-group').find('a:not(.checked)').addClass('checked');
      $('.list-group').find("[type=checkbox]").prop("checked",true);
    }
    else {
      $('.list-group').find('a.checked').removeClass('checked');
      $('.list-group').find("[type=checkbox]").prop("checked",false);
      $this.prop("checked",false);
    }
  });

  $('[type=checkbox]').click(function(e){
    e.stopPropagation();
  });

  /* toggle checkbox when list group item is clicked */
  $('.list-group .list-check').click(function(e){
    $parent = $(this).parents('list-group-item');
    $parent.toggleClass('checked');
    var $this = $(this).find("[type=checkbox]");
    if($this.is(":checked")) {
      $this.prop("checked",false);
    } else {
      $this.prop("checked",true);
    }
  });
});