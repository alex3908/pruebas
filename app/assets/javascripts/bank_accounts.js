document.addEventListener('vue:mounted', () => {
  const clabe_mx = $('#bank_account_clabe');
  clabe_mx.inputmask({ mask: '9999 9999 9999 999999' });

  clabe_mx.on('blur', function() {
    const clabeNum = $(this)
      .val()
      .replace(/[^0-9\.]+/g, '');
    const clabeCheck = clabe.validate(clabeNum);
    const submit_button = $("input[type='submit']");
    const clabe_input = $('#clabe');

    if (clabeNum !== '') {
      if (clabeCheck.ok) {
        submit_button.prop('disabled', false);
        clabe_input.val(clabeCheck.bank);
        Swal.fire({
          title: clabeCheck.bank,
          text: 'La CLABE ' + clabeNum + ' es válida',
          type: 'success',
          confirmButtonText: 'Ok',
        });
      } else {
        submit_button.prop('disabled', true);
        Swal.fire({
          title: '¡Error!',
          text: 'La CLABE es inválida',
          type: 'error',
          confirmButtonText: 'Ok',
        });
      }
    } else {
      submit_button.prop('disabled', false);
    }
  });
});
