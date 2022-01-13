document.addEventListener('vue:mounted', () => {
  const next_order = getOrder();

  hideRemoveButton('.period-row', '#periods');
  hideRemoveButton('.discount-row', '#discounts');
  hideRemoveButton('.down_payment-row', '#down_payments');

  $('#periods')
    .on('cocoon:after-insert', function(e, period) {
      const hidden_orders = $("input[id*='order']");
      hidden_orders[hidden_orders.length - 1].value = next_order;

      if ($('.period-row').length > 1) {
        $('#periods a.remove_fields').show();
      }
    })
    .on('cocoon:after-remove', function(e, period) {
      period.removeClass('period-row');
      if ($('.period-row').length <= 1) {
        $('#periods a.remove_fields').hide();
      } else {
        $('#periods a.remove_fields').show();
      }
    });

  $('#discounts')
    .on('cocoon:after-insert', function() {
      if ($('.discount-row').length > 1) {
        $('#discounts a.remove_fields').show();
      }
    })
    .on('cocoon:after-remove', function(e, discount) {
      discount.removeClass('discount-row');
      if ($('.discount-row').length <= 1) {
        $('#discounts a.remove_fields').hide();
      } else {
        $('#discounts a.remove_fields').show();
      }
    });

  $('#down_payments')
    .on('cocoon:after-insert', function() {
      if ($('.down_payment-row').length > 1) {
        $('#down_payments a.remove_fields').show();
      }
    })
    .on('cocoon:after-remove', function(e, down_payment) {
      down_payment.removeClass('down_payment-row');
      if ($('.down_payment-row').length <= 1) {
        $('#down_payments a.remove_fields').hide();
      } else {
        $('#down_payments a.remove_fields').show();
      }
    });
});

function getOrder() {
  const credit_scheme_id = $('#credit_scheme_credit_scheme_id').val();

  if (credit_scheme_id === '' || typeof credit_scheme_id === 'undefined') {
    return 1;
  }

  const hidden_orders = $("input[id*='order']");

  if (hidden_orders.length > 0) {
    return parseInt(hidden_orders[hidden_orders.length - 1].value) + 1;
  } else {
    $.get(
      window.Routes.period_max_order_credit_scheme_path(credit_scheme_id, {
        format: 'json',
      }),
      function(data) {
        return data;
      }
    );
  }
}

function hideRemoveButton(modelRow, modelId) {
  if ($(`${modelRow}`).length <= 1) {
    $(`${modelId} a.remove_fields`).hide();
  }
}
