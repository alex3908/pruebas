document.addEventListener('vue:mounted', () => {
  $('#send-whatsapp-availability').on('click', function() {
    const url = $(this).data('url');

    window.open(url);
  });
});
