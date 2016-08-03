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

  var start = moment().subtract(29, 'days');
  var end = moment();

  function cb(start, end) {
    $('#datetimepicker').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
  }

  $('#datetimepicker').daterangepicker({
      autoUpdateInput: false,
      startDate: start,
      endDate: end,
      locale: {
        cancelLabel: 'Clear'
      },
      ranges: {
         'Today': [moment(), moment()],
         'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
         'Last 7 Days': [moment().subtract(6, 'days'), moment()],
         'Last 30 Days': [moment().subtract(29, 'days'), moment()],
         'This Month': [moment().startOf('month'), moment().endOf('month')],
         'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
      }
  }, cb);
  $('#datetimepicker').on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format('MM/DD/YYYY') + ' - ' + picker.endDate.format('MM/DD/YYYY'));
  });

  $('#datetimepicker').on('cancel.daterangepicker', function(ev, picker) {
    $(this).val('');
  });

  cb(start, end);

  $('.header-resolve').submit(function(){
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