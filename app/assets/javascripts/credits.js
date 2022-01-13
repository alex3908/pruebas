document.addEventListener('vue:mounted', () => {
  $("input[name^='credit_scheme[requires_file]']").on('change', function() {
    const input_area = $('.is_required_file_active');
    const input_field = input_area.find('select');

    input_area.fadeToggle('slow');
    input_field.prop('disabled', !this.checked).prop('required', this.checked);
  });

  $("input[name^='credit_scheme[cancellation_balance]']").on(
    'change',
    function() {
      const input_area = $('.is_cancellation_balance_active');
      const input_field = input_area.find('select');

      input_area.fadeToggle('slow');
      input_field
        .prop('disabled', !this.checked)
        .prop('required', this.checked);
    }
  );

  const input_delivery_date = $("input[name^='credit_scheme[delivery_date]']");

  if (input_delivery_date.is(':visible')) {
    input_delivery_date.prop('disabled', false).prop('required', true);
  } else {
    input_delivery_date.prop('disabled', true).prop('required', false);
  }

  $("input[name^='credit_scheme[initial_payment_active]']").on(
    'change',
    function() {
      const input_area = $('.is_initial_payment_active');
      const input_field = input_area.find('input');

      input_area.fadeToggle('slow');
      input_field.prop('disabled', !this.checked);
    }
  );

  $("input[name^='credit_scheme[relative_down_payment]']").on(
    'change',
    function() {
      const input_area_for_date = $('.is_relative_down_payment_for_date');
      const input_area_for_max_month = $(
        '.is_relative_down_payment_for_max_month'
      );

      const input_field_for_date = input_area_for_date.find('input');
      const input_field_for_max_month = input_area_for_max_month.find('input');

      input_area_for_date.fadeToggle('slow');
      input_area_for_max_month.fadeToggle('slow');

      input_field_for_max_month.prop('disabled', this.checked);
      input_field_for_date
        .prop('disabled', !this.checked)
        .prop('required', this.checked);
    }
  );

  $("input[name^='credit_scheme[has_last_payment]']").on('change', function() {
    const input_area_for_last_payment_pw = $('.is_last_payment_pw');
    const input_area_for_last_payment_amount = $('.is_last_payment_amount');

    const input_field_for_last_payment_pw = input_area_for_last_payment_pw.find(
      'select'
    );
    const input_field_for_last_payment_amount = input_area_for_last_payment_amount.find(
      'input'
    );

    input_area_for_last_payment_pw.fadeToggle('slow');
    input_area_for_last_payment_amount.fadeToggle('slow');

    input_field_for_last_payment_pw
      .prop('disabled', !this.checked)
      .prop('required', this.checked);

    input_field_for_last_payment_amount
      .prop('disabled', !this.checked)
      .prop('required', this.checked);
  });

  $("input[name^='credit_scheme[is_opening_commission]']").on(
    'change',
    function() {
      const input_area_for_opening_commssion_amount = $(
        '.opening_commission_amount'
      );
      input_area_for_opening_commssion_amount.fadeToggle('slow');
    }
  );

  $("input[name^='credit_scheme[method_payment]']").on('change', function() {
    const input_method_payment = $('.is_payment_methods');
    input_method_payment.fadeToggle('slow');
  });

  $("select[name^='credit_scheme[min_last_payment_payment_way]']").on(
    'change',
    function() {
      const $this = $(this);
      const val = $this.val();

      let label = $('#min_last_payment_amount label');
      let input = $('#min_last_payment_amount input');
      const sign = $('#last_payment_percentage_sign .input-group-text');

      if (val === 'percentage') {
        label.text('Porcentaje mínimo');
        sign.text('%');
        input.attr('max', 100);
        input.val(0);
      }

      if (val === 'amount') {
        label.text('Monto mínimo');
        sign.text('$');
        input.removeAttr('max');
        input.val(0);
      }
    }
  );

  $("input[name^='credit_scheme[is_relative_financing]']").on('change', () => {
    validateRelativeFinancing();
  });

  $("select[name^='credit_scheme[reffered_client_payment_way]']").on(
    'change',
    () => {
      validateReferredClientConfig();
    }
  );
});

function validateRelativeFinancing() {
  const relative_financing_input = $(
    "input[name^='credit_scheme[is_relative_financing]']"
  );
  const relative_down_payment_input = $(
    "input[name^='credit_scheme[relative_down_payment]']"
  );

  const expire_months_input = $("input[name^='credit_scheme[expire_months]']");

  const max_finance_input = $("input[name^='credit_scheme[max_finance]']");

  if (relative_down_payment_input) {
    if (relative_financing_input.is(':checked')) {
      if (relative_down_payment_input.is(':checked')) {
        relative_down_payment_input.prop('checked', false).change();
      }

      max_finance_input.val(1);
      max_finance_input.prop('disabled', true);
      relative_down_payment_input.prop('disabled', true);
    } else {
      max_finance_input.val(0);
      max_finance_input.prop('disabled', false);
      relative_down_payment_input.prop('disabled', false);
    }
  }

  if (expire_months_input) {
    if (relative_financing_input.is(':checked')) {
      if (expire_months_input.is(':checked')) {
        expire_months_input.prop('checked', false).change();
      }
      expire_months_input.prop('disabled', true);
    } else {
      expire_months_input.prop('disabled', false);
    }
  }
}

function validateReferredClientConfig() {
  const $this = $('#credit_scheme_reffered_client_payment_way');
  const val = $this.val();

  let label = $('#reffered_client_amount_container label');
  let input = $('#reffered_client_amount_container input');
  const sign = $('#reffered_client_amount_sing');

  if (val === 'percentage') {
    label.text('Porcentaje de saldo a favor');
    sign.text('%');
    input.attr('max', 100);
  }

  if (val === 'amount') {
    label.text('Monto de saldo a favor');
    sign.text('$');
    input.removeAttr('max');
  }
}
