document.addEventListener('vue:mounted', () => {
  $('select[name="setting[data_type]"]').change(function() {
    const html_editor = $('#trix-editor');
    const percentage_editor = $('#percentage-editor');
    const integer_editor = $('#integer-editor');
    html_editor.css('display', 'none');
    percentage_editor.css('display', 'none');
    integer_editor.css('display', 'none');
    $('textarea', html_editor).prop('disabled', true);
    $('input', percentage_editor).prop('disabled', true);
    $('input', integer_editor).prop('disabled', true);

    switch ($(this).val()) {
      case 'html':
        html_editor.css('display', 'block');
        $('textarea', html_editor).prop('disabled', false);
        break;
      case 'percentage':
        percentage_editor.css('display', 'block');
        $('input', percentage_editor).prop('disabled', false);
        break;
      case 'integer':
        integer_editor.css('display', 'block');
        $('input', integer_editor).prop('disabled', false);
        break;
    }
  });
});
