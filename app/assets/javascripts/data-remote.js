document.addEventListener('vue:mounted', () => {
  $('[data-remote]').on('ajax:beforeSend', function(e, xhr, options) {
    const $body = $('body'),
      $backdrop = $("<div id='backdrop-loader' class='modal-backdrop'></div>"),
      $loader = $(`<div id="loader" class="modal fade" style="display: block;">
        <div class="modal-loader">
        <div class="spinner-border text-light">
        <span class="sr-only">Cargando...</span>
        </div>
        </div>
        </div>`);

    $body.append($backdrop);
    $body.append($loader);
    $backdrop.addClass('show');
    $loader.addClass('show');
    $body.addClass('modal-open');
  });

  $('[data-remote]').on('ajax:complete', function(e, data, status, xhr) {
    const $body = $('body'),
      $backdrop = $('#backdrop-loader'),
      $loader = $('#loader');
    $backdrop.remove();
    $loader.remove();
    if (!$body.hasClass('ignore-modal-close')) {
      $body.removeClass('modal-open');
    }
  });

  $('[data-remote]').on('ajax:error', function(e, xhr, status, err) {
    Swal.fire({
      icon: 'error',
      title: 'Oops...',
      text: 'Hubo un error, por favor inténtalo de nuevo.',
      // footer: '<a href="#">Contactar a soporte</a>',
      customClass: {
        confirmButton: 'btn btn-success',
        cancelButton: 'btn btn-danger',
      },
      buttonsStyling: false,
    });
  });
});
