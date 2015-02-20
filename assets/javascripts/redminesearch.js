var bindLoadMore = function(){
  $("#select2project").select2();
  $("#select2period").select2();
  $("#select2users").select2();
  $("#select2tracker").select2();
  $('#load-more').off("ajax:success").on("ajax:success", function(e, data, status, xhr){
    var entries = $('.tbody_entries');

    entries.find('#load-more-wrapper').remove();
    entries.append(data);
    bindLoadMore();
  }).off("ajax:error").on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.');
  });
}

var bindFilterForm = function(){
  $('#filter-form').on("ajax:success", function(e, data, status, xhr){
    $('.tbody_entries').html(data);
    bindLoadMore();
    bindFilterForm();
  }).on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.');
  });
}

$(function(){
  bindFilterForm();
  $('.filters').hide();
  $('#esearch-form').on("ajax:success", function(e, data, status, xhr){
    $('.filters').show();
    var filter = $('.filters').children();
    var i, _len;
    var val = $('#esearch').val();

    for (i = 0, _len = filter.length; i < _len; i++) {
      filter[i].href = filter[i].href + "&esearch=" + val
    };

    $('.tbody_entries').html(data);
    bindLoadMore();
    bindFilterForm();
  }).on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.');

  });

  $('.filters').on("ajax:success", function(e, data, status, xhr){
    $('.tbody_entries').html(data);
    bindLoadMore();
    bindFilterForm();
  }).on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.');
  });


});