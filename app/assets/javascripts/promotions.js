document.addEventListener('vue:mounted', () => {
  const update_input_type = ($this, input) => {
    const val = $this.val();
    if (val === 'percentage') {
      input.attr('max', 100);
      input
        .next()
        .find('.input-group-text')
        .text('%');
    } else if (val === 'both') {
      input.attr('max', 100);
      input
        .next()
        .find('.input-group-text')
        .text('%');
    } else {
      input.prop('max', null);
      input
        .next()
        .find('.input-group-text')
        .text('$');
    }
  };

  const show_both = (input, $this) => {
    const val = $this.val();
    val === 'both' ? input.show() : input.hide();
  };

  if ($('#promotion_discount_type').val() !== 'both') {
    $('#discount_amount_div').hide();
  }

  $('#promotion_downpayment_type').change(function() {
    update_input_type($(this), $('#promotion_downpayment_amount'));
  });

  $('#promotion_initialpayment_type').change(function() {
    update_input_type($(this), $('#promotion_initialpayment_amount'));
  });

  $('#promotion_discount_type').change(function() {
    update_input_type($(this), $('#promotion_amount'));
    show_both($('#discount_amount_div'), $(this));
  });
});
