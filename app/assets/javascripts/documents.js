document.addEventListener('vue:mounted', () => {
  $('#document_template_doc_type').on('change', function() {
    const doc_type = $('#document_template_doc_type option:selected');
    const sections = doc_type.data('sections');
    const section_select = $('#document_template_document_section_id');
    const folder_documents = $('.folder-document');
    const client_documents = $('.client-document');

    const client_required = $('.client-required');
    const folder_required = $('.folder-required');

    section_select
      .find('option')
      .not(':first')
      .remove();

    client_documents.addClass('d-none');
    folder_documents.addClass('d-none');
    client_required.prop('required', true);
    folder_required.prop('required', true);

    if (doc_type.val() === 'folder') {
      if (sections) {
        sections.forEach(section => {
          section_select.append(
            `<option value="${section.id}">${section.name}</option>`
          );
        });
        section_select.prop('disabled', false);
        section_select.removeClass('bg-input-disabled');
        folder_documents.removeClass('d-none');
      } else {
        section_select.prop('disabled', true);
        section_select.addClass('bg-input-disabled');
      }
      client_required.prop('required', false);
      folder_required.prop('required', true);
    } else if (doc_type.val() == 'client') {
      client_documents.removeClass('d-none');
      client_required.prop('required', true);
      folder_required.prop('required', false);
    }
  });
});
