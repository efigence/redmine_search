$(function(){
  $('.filters').hide();
  $('#esearch-form').on("ajax:success", function(e, data, status, xhr){
    var filter = $('.filters').children();
    var i, _len;
    var val = $('#esearch').val();

    $('.filters').show();
    for (i = 0, _len = filter.length; i < _len; i++) {
      filter[i].href = filter[i].href + "&esearch=" + val
    };

    $('.tbody_entries').html(data);

  }).on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.')
  });

  $('#project-filter').on("ajax:success", function(e, data, status, xhr){
    $('.tbody_entries').html(data);
  }).on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.')
  });

});