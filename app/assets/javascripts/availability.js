//= require rails-ujs
//= require turbolinks
//= require activestorage
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap/dist/js/bootstrap.js
//= require ./data-remote
//= require intl-tel-input
//= require sweetalert2/dist/sweetalert2.js
//= require select2

$(document).on('turbolinks:load', function() {
  $('[rel="tooltip"]').tooltip({ trigger: 'hover' });
  $('.availability [data-id]').on('click', function() {
    const id = $(this).data('id');
    $.get(`/disponibilidad/${id}`);
  });

  $('#send_quote').on('click', function() {
    const $form = $('#quotation-form');
    let can_submit = true;

    $form.find('input').each(function(index) {
      const input = $(this);
      if (!input[0].value && input.attr('type') !== 'hidden') {
        can_submit = false;
        input.parent().addClass('is-invalid');
      } else {
        input.parent().removeClass('is-invalid');
      }
    });

    if (can_submit) {
      $form.attr('method', 'POST');
      $form.submit();
      $form.attr('method', 'GET');
    }
  });

  $('#email').on('change', function() {
    const create_client_button = $('#send_quote');
    let email = $("input[name='email']").val();

    if (validateEmail(email)) {
      create_client_button.prop('disabled', false);
    } else {
      Swal.fire({
        title: '¡Error!',
        text: 'El correo electrónico es inválido',
        type: 'error',
        confirmButtonText: 'Ok',
      });
      create_client_button.prop('disabled', true);
    }
  });

  $('input[type="tel"]').keyup(function(e) {
    if (/\D/g.test(this.value)) {
      // Filter non-digits from input value.
      this.value = this.value.replace(/\D/g, '');
    }
  });

  $('#payment_way, #min_last_payment_payment_way').select2({
    placeholder: 'Seleccione un elemento',
    allowClear: true,
    width: '100%',
  });

  $('#payment_way').on('change', function() {
    const $this = $(this);
    const val = $this.val();

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

  $("select[name^='min_last_payment_payment_way']").on('change', function() {
    const val = $(this).val();
    const sign = $('#last_payment_percentage_sign .input-group-text');

    if (val === 'percentage') {
      sign.text('%');
    }

    if (val === 'amount') {
      sign.text('$');
    }
  });

  $('#total_payments').on('keyup', function() {
    const value = $(this).val();
    const min = 1;
    const max = $('#total_periods').val();
    const Toast = Swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
    });

    const ToastPersistent = Swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
    });

    if (isNaN(value) || value === '') {
      ToastPersistent.fire({
        type: 'warning',
        title: 'Se debe escribir el plazo de pagos.',
      });
    }

    if (parseInt(value) < min) return $(this).val(min);
    else if (parseInt(value) > max) {
      Toast.fire({
        type: 'warning',
        title: `El plazo máximo de financiamiento son ${max} meses.`,
      });
      return $(this).val(max);
    } else return $(this).val(value);
  });
});

function validateEmail(email) {
  let re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(String(email).toLowerCase());
}
