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
    tmpDate = $('#selectPeriod').find(":selected").text();
    if (event.target.value !== "dr") {
      setTimeout(function(){
        var el = $('.js-select2');
        for (var i = el.length - 1; i >= 0; i--) {
          $(el[i]).select2("close");
        };
        $('#filter-form').submit();
        setTimeout(function(){
          $('#selectPeriod').find(":selected").text(tmpDate);
        }, 100);
      }, 100);
    }
  });

  $('#filter-form').on("ajax:success", function(e, data, status, xhr){
    $('.tbody_entries').html(data);
    bindLoadMore();
    bindFilterForm();
    bindModalDate();
  }).on("ajax:error", function(e, xhr, status, error){
    $('#tbody_entries').html('Nie udało się.');
  });
}

var bindModalDate = function() {
  $("#date-from").datepicker({ dateFormat: 'dd-mm-yy' });
  $("#date-to").datepicker({ dateFormat: 'dd-mm-yy' });
  form = $('#filter-form');
  dialog = $( "#dialog-date" ).dialog({
    autoOpen: false,
    height: 200,
    width: 204,
    modal: true,
    draggable: false,
    resizable: false,
    buttons: {
      "OK": function() {
        var from = $("#date-from").val(),
            to = $("#date-to").val();
        $('#fieldDateFrom').val(from);
        $("#fieldDateTo").val(to);
        form.submit();
        dialog.dialog( "close" );
        setTimeout(function(){
          $('#selectPeriod').find(":selected").text(from + " - " + to);
        }, 100);
      }
    }
  });
}

var bindTabs = function() {
  $('#project-filter').click(function(){
    $('#klass').val('Project');
  });

  $('#issue-filter').click(function(){
    $('#klass').val('Issue');
  });
}

var bindConditions = function(){
  bindModalDate();
  $("#select2project").select2({
    placeholder: "Project",
    allowClear: true
  });

  $("#selectPeriod").click(function() {
    if (event.target.value === "dr") {
      element = event.target
      dialog.dialog( "open" );
    }
  });
  $("#select2users").select2({
    placeholder: "User",
    allowClear: true,
    containerCssClass: "UserSelectElement"
  });
  $("#select2tracker").select2({
    placeholder: "Tracker",
    allowClear: true
  });
  $("#select2priority").select2({
    placeholder: "Priority",
    allowClear: true
  });
  $("#select2status").select2({
    placeholder: "Status",
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