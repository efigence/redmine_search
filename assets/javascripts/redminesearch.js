(function($){
  var search = {
    init: function(){
      this.form = $('#esearch-form');
      this.hideFiltersOnStartUp();
      this.bindSelec2();
      this.bindKlassChange();
      this.bindLoadMore();
      this.bindSearchForm();
      this.bindModalDate();
      this.bindSelectPeriod();
      this.bindDateRange();
      this.formSubmit();
    },

    bindSelec2: function(){
      $(".js-select2").each(function(i){
        try { $(this).select2("destroy"); } catch (e) { /* do not care */ }
      });
      $(".js-select2").select2({
        language: "en"
      });

      $(".js-select2-no-search").each(function(i){
        try { $(this).select2("destroy"); } catch (e) { /* do not care */ }
      });
      $(".js-select2-no-search").select2({
        language: "en",
        minimumResultsForSearch: Infinity
      });
    },

    isBlank: function (val) {
      return ( val === '' || val === undefined || val === null )
    },

    // disableFields: function(fields){
    //   fields.attr("disabled", "disabled");
    // },

    // enableFields: function(fields){
    //   fields.removeAttr("disabled");
    // },

    hideBaseFilters: function() {
      $('.base-filters').hide()
    },

    showBaseFilters: function() {
      $('.base-filters').show()
    },

    hideCommonFilters: function() {
      $('.common-filters').hide()
    },

    showCommonFilters: function() {
      $('.common-filters').css('display', 'inline-block')
    },

    hideSpecificFilters: function() {
      $.each([ 'Issue', 'Project', 'WikiPage' ], function( index, value ) {
        $('.'+value+'-filters').hide();
      });
    },

    hideAllFilters: function() {
        this.hideBaseFilters();
        this.hideSpecificFilters();
        this.hideCommonFilters();
    },

    bindKlassChange: function(){
      var $this = this;
      $('input[name=klass]', '.klass-filters').on('change', function(){
        if( !$this.isBlank($('#esearch').val())){
          $('.filters-wrpper').hide();
          klass = $(this).val();
          $this.showBaseFilters();
          $this.hideSpecificFilters();
          $('.'+klass+'-filters').css('display', 'inline');
          if (klass === 'Issue' || klass == 'WikiPage'){
            $this.showCommonFilters();
          }
          $('.filters-wrpper').show();
          $this.bindSelec2();
          $this.form.submit();
        }
      })
    },


    hideFiltersOnStartUp: function(){
      this.hideSpecificFilters();
      this.showBaseFilters();
      klass = $('input[name=klass]:checked', '.klass-filters').val()
      $('.'+klass+'-filters').css('display', 'inline');
      if (klass === 'Issue' || klass == 'WikiPage'){
        this.showCommonFilters();
      }
      $('.filters-wrpper').show();
    },

    bindLoadMore: function(){
      var $this = this;
      $('#load-more').off("ajax:success").on("ajax:success", function(e, data, status, xhr){
        var entries = $('.tbody_entries:last');

        entries.find('#load-more-wrapper').remove();
        data = $(data);
        entries.after(data);
        $this.scrollTo(data);
        $this.bindLoadMore();
      }).off("ajax:error").on("ajax:error", function(e, xhr, status, error){
        $('#tbody_entries').html('Nie udało się.');
      });
    },

    bindSearchForm: function(){
      var $this = this;
      this.form.on("ajax:success", function(e, data, status, xhr){
        $(".list.issues thead").remove();
        $(".tbody_entries:not(:first)").remove();
        var el = $('.tbody_entries:first').replaceWith(data)
        $this.bindLoadMore();
        $this.hideFiltersOnStartUp();
      }).on("ajax:error", function(e, xhr, status, error){
        $('#tbody_entries').html('Nie udało się.');
      });
    },

    bindModalDate: function() {
      var $this = this;
      $("#date-from").datepicker({ dateFormat: 'dd-mm-yy' });
      $("#date-to").datepicker({ dateFormat: 'dd-mm-yy' });
      form = $('#filter-form');
      this.dialog = $( "#dialog-date" ).dialog({
        autoOpen: false,
        height: 200,
        width: 204,
        modal: true,
        draggable: false,
        resizable: false,
        buttons: {
          "OK": function() {
            var period = $("#period"),
              from = $('#date-from').val(),
              to = $('#date-to').val();

            if ($this.isBlank(from) && $this.isBlank(to)){
              return false;
            }

            if ($this.isBlank(from)){
              from = '&infin;'
            }
            if ($this.isBlank(to)){
              to = '&infin;'
            }

            period.find('option:last').empty().append(from + ' &mdash; ' + to);
            period.select2("destroy");
            period.select2({
              language: "en",
              minimumResultsForSearch: Infinity
            });
            $this.bindSelectPeriod()
            $this.form.submit();
            $this.dialog.dialog( "close" );
          }
        }
      });
    },

    bindSelectPeriod: function(){
      var $this = this;
      $("#period").off("select2:closing").on("select2:closing", function(e) {
        var val = $(this).val();
        if (val === "dr") {
          $this.dialog.dialog( "open" );
        } else {
          $this.form.submit();
        }
      });
    },

    bindDateRange: function(){
      $('#date-from').on('change', function(){
        $('#hidden-date-from').val($(this).val())
      })
      $('#date-to').on('change', function(){
        $('#hidden-date-to').val($(this).val())
      })
    },

    formSubmit: function(){
      var $this = this;
      $('.js-submit-form').on('change', function(){
        $this.form.submit();
      });
    },

    scrollTo: function(element){
      return $('html, body').animate({
        scrollTop: element.offset().top - 100
      }, 1000);
    }

  }

  $(function(){
    search.init();
  });
})(jQuery)
