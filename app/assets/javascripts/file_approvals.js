document.addEventListener('vue:mounted', () => {
  $(
    '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_project_id_eq'
  ).on('change', function() {
    const phases = $(
      '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_project_id_eq option:selected'
    ).data('phases');
    const phases_select = $(
      '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_id_eq'
    );
    const stage_select = $(
      '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_id_eq'
    );

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

  $(
    '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_id_eq'
  ).on('change', function() {
    const stages = $(
      '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_id_eq option:selected'
    ).data('stages');
    const stages_select = $(
      '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_id_eq'
    );

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

  const url_string = window.location.href;
  let url = new URL(url_string);
  if (
    url.searchParams.get(
      'approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_project_id_eq'
    )
  ) {
    const phases = $(
      '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_project_id_eq option:selected'
    ).data('phases');
    const phase_select = $(
      '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_id_eq'
    );

    phase_select
      .find('option')
      .not(':first')
      .remove();
    if (phases) {
      phases.forEach(phase => {
        const phase_active = url.searchParams.get(
          'approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_id_eq'
        );
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

      const stages = $(
        '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_phase_id_eq option:selected'
      ).data('stages');
      const stage_select = $(
        '#q_approvable_of_Document_type_documentable_of_Folder_type_lot_stage_id_eq'
      );
      stage_select
        .find('option')
        .not(':first')
        .remove();
      if (stages) {
        stages.forEach(stage => {
          const stage_active = url.searchParams.get(
            'approvable_of_Document_type_documentable_of_Folder_type_lot_stage_id_eq'
          );
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
});
