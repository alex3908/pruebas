document.addEventListener('vue:mounted', () => {
  $('.voucher').click(function() {
    $('input[name="payment[voucher]"]').click();
  });

  $('input[name="payment[voucher]"]').on('change', function() {
    $('.voucher').addClass('icon-file-uploaded');
    $('.file-submit').prop('disabled', false);
  });

  $('#paymentModal').on('show.bs.modal', event => {
    const payment = $(event.relatedTarget);

    // Get payment values
    const number = payment.data('number');
    const date = payment.data('date');
    const capital = payment.data('capital');
    const interest = payment.data('interest');
    const down_payment = payment.data('down_payment');
    const total = payment.data('payment');
    const amount = payment.data('amount');

    // Set payment values
    $('#payment-number').text(number);
    $('#payment-date').text(date);
    $('#payment-capital').text(capital);
    $('#payment-interest').text(interest);
    $('#payment-down_payment').text(down_payment);
    $('#payment-total').text(total);
    $('#payment-amount').text(amount);
  });
});
