$(document).on('turbolinks:load', function() {
  $('[data-remote]').on('ajax:complete', function(e, data, status, xhr) {
    const file_manager = $('.file_manager');
    if (file_manager.length && file_manager.hasClass('show')) {
      $('body').addClass('modal-open');
    }
  });
});
