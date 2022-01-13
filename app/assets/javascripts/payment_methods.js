document.addEventListener('vue:mounted', () => {
  $("input[name^='payment_method[cash_back]']").change(function() {
    const input_area = $('#concepts');
    const input_field = input_area.find('select');

    input_area.fadeToggle('slow');

    if (this.checked) {
      input_field.prop('disabled', false);
    } else {
      input_field.prop('disabled', true);
    }
  });

  $("input[name^='payment_method[reffered_client_cash_back_multiple]']").change(
    function() {
      const folder_exclusivity = $(
        "input[name^='payment_method[cash_back_folder_exclusivity]']"
      );

      if (folder_exclusivity.is(':checked')) {
        folder_exclusivity.prop('checked', false).change();
      }

      if (this.checked) {
        folder_exclusivity.prop('disabled', true);
      } else {
        folder_exclusivity.prop('disabled', false);
      }
    }
  );

  $("input[name^='payment_method[payment_is_income]']").change(function() {
    const folder_exclusivity = $("input[name^='payment_method[cash_back]']");

    if (folder_exclusivity.is(':checked')) {
      folder_exclusivity.prop('checked', false).change();
    }

    if (this.checked) {
      folder_exclusivity.prop('disabled', true);
    } else {
      folder_exclusivity.prop('disabled', false);
    }
  });
});
