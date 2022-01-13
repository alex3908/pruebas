document.addEventListener('vue:mounted', () => {
  $('#quote #reserve, #quote #save').on('click', function(e) {
    const $form = $('#quote');
    const {
      dataset: { hascustominstallments, hascustompayments },
    } = e.currentTarget;

    if (hascustompayments === 'true') {
      Swal.fire({
        type: 'warning',
        title: 'Existen pagos de cuotas personalizadas',
        text:
          'Si desea editar el financiamiento deberá realizar la cancelación de los pagos.',
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger',
        },
        confirmButton: false,
        cancelButton: true,
        buttonsStyling: false,
      });

      return;
    }

    if (hascustominstallments === 'true') {
      Swal.fire({
        title:
          '¿Seguro que deseas guardar las modificaciones del financiamiento?',
        text:
          'Recuerda que al confirmar esta acción las cuotas personalizadas existentes dejarán de estar disponibles.',
        type: 'warning',
        showCancelButton: true,
        closeOnCancel: true,
        allowOutsideClick: false,
        cancelButtonText: 'No, Cancelar.',
        confirmButtonText: 'Sí, Continuar.',
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger ml-2',
        },
        buttonsStyling: false,
      }).then(isConfirm => {
        const { value = false } = isConfirm;
        if (value) {
          $form.attr('method', 'POST');
          $form.submit();
          $form.attr('method', 'GET');
        }
      });
    } else {
      $form.attr('method', 'POST');
      $form.submit();
      $form.attr('method', 'GET');
    }
  });

  $('#quote #send_email').on('click', function(e) {
    const $form = $('#quote');

    const $input = $('<input>').attr({
      type: 'hidden',
      id: 'email',
      name: 'email',
      value: 'true',
    });

    $input.appendTo($form);
    $form.submit();
    $input.remove();
  });

  $('#quote #download_pdf').on('click', function(e) {
    e.preventDefault();
    const $form = $('#quote'),
      params = $form.serialize(),
      location = window.location;
    const host = location.protocol + '//' + location.host + location.pathname;
    const pdf_url = host + '.pdf?' + params;
    const win = window.open(pdf_url, '_blank');
    win.focus();
    return false;
  });

  $('#payment_way').change(function() {
    const $this = $(this);
    const val = $this.val();

    if (!['percentage', 'amount'].includes(val)) {
      return;
    }

    const sign = $('#down_payment_percentage_sign .input-group-text'),
      label = $('#down_payment_amount label');
    if (val === 'percentage') {
      label.text('Porcentaje de enganche');
      sign.text('%');
    }

    if (val === 'amount') {
      label.text('Monto de enganche');
      sign.text('$');
    }
  });

  $('#custom_down_payment_differ').change(function() {
    const $form = $('#quote');
    $form.submit();
  });

  $('#custom_commissionable').change(function() {
    const $form = $('#quote');
    $form.submit();
  });

  $("select[name^='min_last_payment_payment_way']").on('change', function() {
    const $this = $(this);
    const val = $this.val();
    const sign = $('#last_payment_percentage_sign .input-group-text');

    if (val === 'percentage') {
      sign.text('%');
    }

    if (val === 'amount') {
      sign.text('$');
    }
  });
});
