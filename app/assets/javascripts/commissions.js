document.addEventListener('vue:mounted', () => {
  $('.voucher').click(function() {
    $('input[name="commission[voucher]"]').click();
  });

  $('input[name="commission[voucher]"]').on('change', function() {
    $('.voucher').addClass('icon-file-uploaded');
    $('.file-submit').prop('disabled', false);
  });

  $('.invoice').click(function() {
    $('input[name="commission[invoice]"]').click();
  });

  $('input[name="commission[invoice]"]').on('change', function() {
    $('.invoice').addClass('icon-file-uploaded');
    $('.file-submit').prop('disabled', false);
  });
});
