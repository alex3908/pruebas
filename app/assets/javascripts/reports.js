document.addEventListener('vue:mounted', () => {
  $('.project').on('change', function() {
    const phases = $('.project option:selected').data('phases');
    const phases_select = $('.phase');
    const stage_select = $('.stage');

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

  $('.phase').on('change', function() {
    const stages = $('.phase option:selected').data('stages');
    const stages_select = $('.stage');

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
  if (url.searchParams.get('project')) {
    const phases = $('.project option:selected').data('phases');
    const phase_select = $('.phase');

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

      const stages = $('.phase option:selected').data('stages');
      const stage_select = $('.stage');
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

  $('#payment_date').on('click', function() {
    $('.reserve_date_section').addClass('d-none');
    $('#q_installment_folder_created_at_gteq').attr('disabled', 'disabled');
    $('#q_installment_folder_created_at_end_of_day_lteq').attr(
      'disabled',
      'disabled'
    );

    $('.cash_flow_date_section').addClass('d-none');
    $('#q_cash_flow_created_at_gteq').attr('disabled', 'disabled');
    $('#q_cash_flow_created_at_end_of_day_lteq').attr('disabled', 'disabled');

    $('.payment_date_section').removeClass('d-none');
    $('#q_created_at_gteq').removeAttr('disabled');
    $('#q_created_at_end_of_day_lteq').removeAttr('disabled');
  });

  $('#reserve_date').on('click', function() {
    $('.payment_date_section').addClass('d-none');
    $('#q_created_at_gteq').attr('disabled', 'disabled');
    $('#q_created_at_end_of_day_lteq').attr('disabled', 'disabled');

    $('.cash_flow_date_section').addClass('d-none');
    $('#q_cash_flow_created_at_gteq').attr('disabled', 'disabled');
    $('#q_cash_flow_created_at_end_of_day_lteq').attr('disabled', 'disabled');

    $('.reserve_date_section').removeClass('d-none');
    $('#q_installment_folder_created_at_gteq').removeAttr('disabled');
    $('#q_installment_folder_created_at_end_of_day_lteq').removeAttr(
      'disabled'
    );
  });

  $('#cash_flow_date').on('click', function() {
    $('.payment_date_section').addClass('d-none');
    $('#q_created_at_gteq').attr('disabled', 'disabled');
    $('#q_created_at_end_of_day_lteq').attr('disabled', 'disabled');

    $('.reserve_date_section').addClass('d-none');
    $('#q_installment_folder_created_at_gteq').attr('disabled', 'disabled');
    $('#q_installment_folder_created_at_end_of_day_lteq').attr(
      'disabled',
      'disabled'
    );

    $('.cash_flow_date_section').removeClass('d-none');
    $('#q_cash_flow_created_at_gteq').removeAttr('disabled');
    $('#q_cash_flow_created_at_end_of_day_lteq').removeAttr('disabled');
  });
});
