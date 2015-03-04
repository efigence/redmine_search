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
    if (event.target.value !== "dr") {
      setTimeout(function(){
        var el = $('.js-select2');
        for (var i = el.length - 1; i >= 0; i--) {
          $(el[i]).select2("close");
        };
        $('#filter-form').submit();
      }, 100);
    }
  });

  $('#filter-form').on("ajax:success", function(e, data, status, xhr){
    $('.tbody_entries').html(data);
    bindLoadMore();
    bindFilterForm();
    bindModalDate();
    setSearchPeriod();
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
      }
    }
  });
}
var setSearchPeriod = function() {
  // set main search input filters
  var period = $('#selectPeriod').val(),
      from = $('#fieldDateFrom').val(),
      to = $("#fieldDateTo").val();
  $('#period').val(period);
  if (period === "dr") {
    $('#from').val(from);
    $('#to').val(to);
  }
}

var setCurrentPeriod = function(el) {
  // set href to tabs with period
  var period = $('#selectPeriod').val()
  el.href = el.href + '&period=' + period;
  if (period === "dr") {
    el.href = el.href + '&from=' + $('#fieldDateFrom').val();
    el.href = el.href + '&to=' + $('#fieldDateTo').val();
  }
}
var bindTabs = function() {
  $('#project-filter').click(function(){
    $('.ui-dialog').remove();
    $('#klass').val('Project');
    setSearchPeriod();
    setCurrentPeriod(this);
   });

  $('#issue-filter').click(function(){
    $('.ui-dialog').remove();
    $('#klass').val('Issue');
    setSearchPeriod();
    setCurrentPeriod(this);
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
  $("#select2roles").select2({
    placeholder: "My roles",
    allowClear: true
  });
}

$(function(){
  $('.filters').hide();
  bindLoadMore();
  bindTabs();
  bindFilterForm();
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