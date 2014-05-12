// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/backend/all.js'
//= require spree/backend

function display_explicit_or_factored_pb_fields() {
  if ($("#price_book_parent_id").length > 0) {
    if ($("#price_book_parent_id option:selected").val() == "") {
      $("#price_book_price_adjustment_factor").val('');
      $("#price_book_price_adjustment_factor_field").hide();
    } else {
      $("#price_book_price_adjustment_factor_field").show();
    }
  }
}

$(function() {
  display_explicit_or_factored_pb_fields();

  $("#content").on('change', '#price_book_parent_id', display_explicit_or_factored_pb_fields);

  $('.master').on('change', function() {
    saved = this;
    $(this).closest('form').find("input[type=text]").not(this).each(
      function(index, ele) {
        if ($(ele).val() == '') {
          $(ele).val($(saved).val());
        }
    });
  });

  $('#price_book_id').on('change', function() {
     $(this).closest('form').find("input[type=text]").val("");
     $(this).closest('form').submit();
  });

  $('.sortable').sortable({
    update: function (event, ui) {
      var data = $(this).sortable('serialize', { key: 'store_price_book_id[]' });
      $.ajax({
        data: data,
        type: 'POST',
        url: $(this).data('href')
      });
    }
  });

});
