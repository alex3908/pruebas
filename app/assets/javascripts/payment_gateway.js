document.addEventListener('vue:mounted', () => {
  $('#pay-button').on('click', function(event) {
    OpenPay.setId(document.getElementById('merchant_id').value);
    OpenPay.setApiKey(document.getElementById('public_key').value);
    OpenPay.setSandboxMode(true);
    OpenPay.deviceData.setup('payment-form', 'device_session_id');
    const holder_name = $('#holder_name').val();
    const card_number = $('#card_number')
      .val()
      .replace(/\s+/g, '');
    const expiration_month = $('#expiration_month').val();
    const expiration_year = $('#expiration_year').val();
    const cvv2 = $('#cvv2')
      .val()
      .replace(/_+/g, '');
    const payment_form = {
      holder_name: holder_name,
      card_number: card_number,
      expiration_month: expiration_month,
      expiration_year: expiration_year,
      cvv2: cvv2,
    };
    OpenPay.token.create(payment_form, success_callback, error_callback);
  });

  const success_callback = function(response) {
    $('#token_id').val(response.data.id);
    $('#payment-form').submit();
  };

  const error_callback = function(response) {
    const desc =
      response.data.description !== undefined
        ? response.data.description
        : response.message;
    alert('ERROR [' + response.status + '] ' + desc);
    $('#pay-button').prop('disabled', false);
  };

  $('#card_number').inputmask({ mask: '9999 9999 9999 9999' });
  $('#expiration_month').inputmask({ mask: '99' });
  $('#expiration_year').inputmask({ mask: '99' });
  $('#cvv2').inputmask({ mask: '9999' });
});
