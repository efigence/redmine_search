var bindLoadMore = function(){
  bindConditions();
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
  $('#filter-form').change(function(){
    setTimeout(function(){
      var el = $('.js-select2');
      for (var i = el.length - 1; i >= 0; i--) {
        $(el[i]).select2("close");
      };
      $('#filter-form').submit();
    }, 100);
  });

  $('#filter-form').on("ajax:success", function(e, data, status, xhr){
    $('.tbody_entries').html(data);
    bindLoadMore();
    bindFilterForm();
  }).on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.');
  });
}

var bindTabs = function(){
  $('#project-filter').click(function(){
    $('#klass').val('Project');
  });

  $('#issue-filter').click(function(){
    $('#klass').val('Issue');
  });
}

var bindConditions = function(){
  $("#select2project").select2({
    placeholder: "Select projects",
    allowClear: true
  });
  $("#select2period").select2({
    placeholder: "Select period",
    allowClear: true
  });
  $("#select2users").select2({
    placeholder: "Select users",
    allowClear: true
  });
  $("#select2tracker").select2({
    placeholder: "Select trackers",
    allowClear: true
  });
  $("#select2priority").select2({
    placeholder: "Selecet priorities",
    allowClear: true
  });
}

$(function(){
  bindTabs();
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