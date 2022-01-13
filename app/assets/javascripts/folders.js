document.addEventListener('vue:mounted', () => {
  $('#reassignClientModal, #reassignUserModal, #coownerModal').on(
    'hidden.bs.modal',
    function(e) {
      $('.autocomplete-input').val('');
      $('.autocomplete-hidden').val('');
    }
  );

  $('.search-subordinates').on('change', function(e) {
    const sub_select = e.currentTarget;
    const selectedIndex = sub_select.selectedIndex;
    const child = sub_select.dataset.child || '';
    const options = sub_select.options || [];

    if (child.length === 0) {
      return;
    }
    if (selectedIndex <= 0) {
      $(`#${child}-container`).addClass('d-none');
      $(`#${child}_node`)
        .val('')
        .trigger('change');
      return;
    }

    const { value } = options[selectedIndex];
    $(`#${child}-container`).removeClass('d-none');
    if (value.length > 0) {
      searchSubordinates(value, `#${child}_node`);
    }
  });

  $('#coownerModal').on('show.bs.modal', function(event) {
    let button = $(event.relatedTarget);
    let save_coowner = $('#saveCoowner');
    let id = button.data('folder_id');
    save_coowner.data('folder_id', id);
  });

  $('[data-toggle="tooltip"]').tooltip();

  $('#saveCoowner').click(function() {
    let folder_id = $(this).data('folder_id');
    let client_selected = $('input[name=client]').val();
    let folder_url = '/folders/' + folder_id + '/add_client';
    let folder_json = { client: client_selected };

    if (client_selected !== '') {
      $.ajax({
        type: 'POST',
        contentType: 'application/json',
        url: folder_url,
        data: JSON.stringify(folder_json),
        success: function() {
          $('#saleModal').modal('hide');
        },
        error: function(data) {},
      });
    } else {
      Swal.fire({
        title: 'Error!',
        text: 'Necesitas selecionar un cliente',
        type: 'error',
        confirmButtonText: 'Ok',
      });
    }
  });

  // This turns color of the cloud after picking a file.
  $('[data-document-input]').on('change', function() {
    $(this)
      .closest('tr')
      .find('[data-upload-icon]')
      .addClass('icon-file-uploaded');
  });

  $('#project').on('change', function() {
    const phases = $('#project option:selected').data('phases');
    const phases_select = $('#phase');
    const stage_select = $('#stage');

    phases_select
      .find('option')
      .not(':first')
      .remove();
    stage_select
      .find('option')
      .not(':first')
      .remove();

    stage_select.prop('disabled', true);
    stage_select.addClass('bg-input-disabled');

    if (phases) {
      phases.forEach(phase => {
        phases_select.append(`
          <option value="${phase.id}" data-stages='${JSON.stringify(
          phase.stages
        )}'>
            ${phase.name}
          </option>`);
      });
      phases_select.prop('disabled', false);
      phases_select.removeClass('bg-input-disabled');
    } else {
      phases_select.prop('disabled', true);
      phases_select.addClass('bg-input-disabled');
    }
  });

  $('#phase').on('change', function() {
    const stages = $('#phase option:selected').data('stages');
    const stages_select = $('#stage');

    stages_select
      .find('option')
      .not(':first')
      .remove();

    if (stages) {
      stages.forEach(stage => {
        stages_select.append(
          `<option value=${stage.id}>${stage.name}</option>`
        );
      });
      stages_select.prop('disabled', false);
      stages_select.removeClass('bg-input-disabled');
    } else {
      stages_select.prop('disabled', true);
      stages_select.addClass('bg-input-disabled');
    }
  });

  $("input[name^='credit_balance']").on('change', function() {
    const input_area = $('.is_credit_balance_active');
    const input_field = input_area.find('select');

    input_area.fadeToggle('slow');
    input_field.prop('disabled', !this.checked).prop('required', this.checked);
  });

  const url_string = window.location.href;
  let url = new URL(url_string);
  if (url.searchParams.get('project')) {
    const phases = $('#project option:selected').data('phases');
    const phase_select = $('#phase');

    phase_select
      .find('option')
      .not(':first')
      .remove();
    if (phases) {
      phases.forEach(phase => {
        const phase_active = url.searchParams.get('phase');
        if (Number(phase_active) === phase.id) {
          phase_select.append(
            '<option value=' +
              phase.id +
              " data-stages='" +
              JSON.stringify(phase.stages) +
              "'selected>" +
              phase.name +
              '</option>'
          );
        } else {
          phase_select.append(
            '<option value=' +
              phase.id +
              " data-stages='" +
              JSON.stringify(phase.stages) +
              "'>" +
              phase.name +
              '</option>'
          );
        }
      });

      phase_select.prop('disabled', false);
      phase_select.removeClass('bg-input-disabled');

      const stages = $('#phase option:selected').data('stages');
      const stage_select = $('#stage');
      stage_select
        .find('option')
        .not(':first')
        .remove();
      if (stages) {
        stages.forEach(stage => {
          const stage_active = url.searchParams.get('stage');
          if (Number(stage_active) === stage.id) {
            stage_select.append(
              '<option value=' +
                stage.id +
                ' selected>' +
                stage.name +
                '</option>'
            );
          } else {
            stage_select.append(
              '<option value=' + stage.id + '>' + stage.name + '</option>'
            );
          }
        });
        stage_select.prop('disabled', false);
        stage_select.removeClass('bg-input-disabled');
      }
    }
  }
  const status_param = url.searchParams.get('status');
  const step_active = url.searchParams.get('step');
  if (status_param === 'active') {
    const steps = $('#status option:selected').data('steps');
    const step_select = $('#step');
    step_select.prop('disabled', false);
    step_select.removeClass('bg-input-disabled');
    steps.forEach(step => {
      step_select.append(
        `<option value=${step.id} ${step_active == step.id ? 'selected' : ''}>
          ${step.name}
        </option>`
      );
    });
  }

  $('#status').on('change', function() {
    const status = $('#status option:selected').val();
    const steps = $('#status option:selected').data('steps');
    const step_select = $('#step');
    if (status == 'active' && steps) {
      steps.forEach(step => {
        step_select.append(`<option value=${step.id}>${step.name}</option>`);
      });
      step_select.prop('disabled', false);
      step_select.removeClass('bg-input-disabled');
    } else {
      step_select.prop('disabled', true);
      step_select.addClass('bg-input-disabled');
      step_select
        .find('option')
        .not(':first')
        .remove();
    }
  });
  initFolderUserConceptChange();
});
const initFolderUserConceptChange = () => {
  $('#folder_user_folder_user_concept_id').on('change', function() {
    const id = $('#folder_user_folder_user_concept_id option:selected').val();
    const url = '/folder_user_concepts/' + id + '/users';
    $.ajax({
      type: 'GET',
      url: url,
    });
  });
};

const searchSubordinates = (user_id, container) => {
  const url = `/structures/get_subordinates/${user_id}`;

  $.ajax({
    type: 'GET',
    contentType: 'application/json',
    url: url,
    success: function(levels) {
      $(container).html('');

      const options = [];
      levels.forEach(level => {
        options.push(new Option(level.name, level.id, false));
      });

      const empty_option = new Option('', '', false);

      $(container).append(empty_option);

      if (options.length > 0) {
        $(container).append(options);
      }

      $(container).trigger('change');
    },
    error: function(response) {
      console.error(response);
      Swal.fire({
        title: '¡Ocurrió un error!',
        text: 'Por favor contacta a tu responsable',
        type: 'error',
        confirmButtonText: 'Ok',
      });
    },
  });
};
