document.addEventListener('vue:mounted', () => {
  const blueprint_stage_url = (project, phase, blueprint, blueprint_stage) =>
    `/projects/${project}/phases/${phase}/blueprints/${blueprint}/blueprint_stages/${blueprint_stage}.json`;

  $("input[name^='complete-stage-']").change(function() {
    const Toast = Swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
    });
    const stage = $(this).data('stage-id');
    const phase = $(this).data('phase-id');
    const project = $(this).data('project-id');
    const toggle_json = {
      active: $(this).val(),
    };
    const url =
      '/projects/' +
      project +
      '/phases/' +
      phase +
      '/stages/' +
      stage +
      '/status';
    const parent_toggle = $('#complete-stage-' + stage)
      .parent()
      .hasClass('off');

    $.ajax({
      type: 'PUT',
      contentType: 'application/json',
      url: url,
      data: JSON.stringify(toggle_json),
      success: function(data) {
        if (data.status === 'error' && !parent_toggle) {
          $('#complete-stage-' + stage).bootstrapToggle('off');
        } else {
          Toast.fire({
            type: data.status,
            title: data.message,
          });
        }
      },
      error: function(error) {
        console.log(error);
      },
    });
  });

  $(
    "input[name^='down_payment_differ'], input[name^='custom_down_payment_differ']"
  ).change(function() {
    const down_payment_not_differ = $(this)
      .parent()
      .hasClass('off');

    if (down_payment_not_differ) {
      const custom_start_installments = $('#custom_start_installments');

      custom_start_installments.prop('disabled', true);
      custom_start_installments.val('');
      $('#stage_start_installments').prop('disabled', true);
      $('#promotion_start_installments').prop('disabled', true);
    } else {
      $('#stage_start_installments').prop('disabled', false);
      $('#custom_start_installments').prop('disabled', false);
      $('#promotion_start_installments').prop('disabled', false);
    }
  });

  $("input[name^='is_immediate_construction']").change(function() {
    const input_area = $('#immediate_extra_months');
    const input_field = input_area.find('input');

    input_area.fadeToggle('slow');

    if (this.checked) {
      input_field.prop('disabled', false);
    } else {
      input_field.prop('disabled', true);
    }
  });

  $('input:file').change(function() {
    if ($(this).val()) {
      $('input:submit').attr('disabled', false);
    }
  });

  $('#assignStageModal').on('show.bs.modal', function(event) {
    const stage_name = $(event.relatedTarget).data('stage-name');
    $('#stage_name').text(stage_name);
    $('#assign_stage').data('stage_name', stage_name);

    const stage_id = $(event.relatedTarget).data('stage-id');
    $('#stage_id').val(stage_id);

    const project_id = $(event.relatedTarget).data('project-id');
    $('#project_id').val(project_id);

    const phase_id = $(event.relatedTarget).data('phase-id');
    $('#phase_id').val(phase_id);
  });

  $('.stage-assignable').click(function(e) {
    const $this = $(this); // Polygon that triggered the modal

    const Toast = Swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
    });

    const project_id = $('#project_id').val(),
      phase_id = $('#phase_id').val(),
      stage_id = $('#stage_id').val(),
      blueprint_stage_id = $this.data('blueprint-stage-id'),
      blueprint_id = $this.data('blueprint-id');

    $.ajax({
      type: 'PUT',
      contentType: 'application/json',
      url: blueprint_stage_url(
        project_id,
        phase_id,
        blueprint_id,
        blueprint_stage_id
      ),
      data: JSON.stringify({ blueprint_stage: { stage_id } }),
      success: blueprint => {
        $this.addClass('assigned');
        $this.removeClass('assignable');
        $this.data('id', blueprint.id);
        $this.data('status', blueprint.stage.status);
        $this.attr('data-original-title', `${blueprint.stage.name}`);
        $(`[data-id=${stage_id}]`)
          .find('.deallocate-button')
          .show();
        $(`[data-id=${stage_id}]`)
          .find('.assign-button')
          .hide();
        $('#assignStageModal').modal('hide');
        Toast.fire({
          type: 'success',
          title: `Privada ${blueprint.stage.name} asignada.`,
        });
      },
      error: function(error) {
        console.log(error);
        $('#assignLotModal').modal('hide');
        Toast.fire({
          type: 'warn',
          title: 'Hubo un error, por favor inténtalo de nuevo.',
        });
      },
    });
  });

  $('#stage_commission_scheme_id').change(function() {
    let url = `/projects/${$(this).data('project-id')}/phases/${$(this).data(
      'phase-id'
    )}/stages/show_stage_commission_schemes_roles`;

    $.ajax({
      type: 'GET',
      contentType: 'application/json',
      url: url,
      data: {
        stage_id: $(this).data('stage-id'),
        commission_scheme_id: $(this).val(),
      },
      success: function(data) {
        $('#stage_commission').html(data);
        $('select:not(.not-select2)').each(function() {
          initSelect2(this);
        });
        $('#stage_commission input[name=authenticity_token]').remove();
      },
      error: function(error) {
        console.error(error);
      },
    });
  });
  $('#stage_commission_scheme_id').trigger('change');
});
