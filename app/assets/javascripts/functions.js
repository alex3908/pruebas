function upperCase(element) {
  return $(element).val(element.value.toUpperCase());
}

function validateEmail(email) {
  let re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(String(email).toLowerCase());
}

document.addEventListener('vue:mounted', () => {
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
