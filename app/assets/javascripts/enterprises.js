document.addEventListener('vue:mounted', () => {
  $('#enterprise_rfc').on('blur', function() {
    let rfcFormat;
    const $this = $('#enterprise_rfc'),
      value = $this.val();
    if (value.length == 12) {
      rfcFormat = '^(([A-Z]|[a-z]){3})([0-9]{6})((([A-Z]|[a-z]|[0-9]){3}))';
    } else {
      rfcFormat =
        '^(([A-Z]|[a-z]|s){1})(([A-Z]|[a-z]){3})([0-9]{6})((([A-Z]|[a-z]|[0-9]){3}))';
    }
    const validRfc = new RegExp(rfcFormat);
    const matchArray = value.match(validRfc);
    if (matchArray == null) {
      $this.addClass('is-invalid');
      $this.removeClass('is-valid');
      return false;
    } else {
      $this.removeClass('is-invalid');
      $this.addClass('is-valid');
      return true;
    }
  });
  (function() {
    'use strict';
    window.addEventListener(
      'load',
      function() {
        // Fetch all the forms we want to apply custom Bootstrap validation styles to
        var forms = document.getElementsByClassName('needs-validation');
        // Loop over them and prevent submission
        var validation = Array.prototype.filter.call(forms, function(form) {
          form.addEventListener(
            'submit',
            function(event) {
              if (form.checkValidity() === false) {
                event.preventDefault();
                event.stopPropagation();
              }
              form.classList.add('was-validated');
            },
            false
          );
        });
      },
      false
    );
  })();
});
