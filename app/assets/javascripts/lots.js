document.addEventListener('vue:mounted', () => {
  const blueprint_lot_url = (project, phase, stage, blueprint, blueprint_lot) =>
    `/projects/${project}/phases/${phase}/stages/${stage}/blueprints/${blueprint}/blueprint_lots/${blueprint_lot}.json`;
  const status_label = status => {
    if (status === 'for_sale') {
      return 'Disponible';
    }
    if (status === 'reserved') {
      return 'Reservado';
    }
    if (status === 'sold') {
      return 'Vendido';
    }
    if (status === 'locked') {
      return 'Fuera de Venta';
    }
  };

  $('[rel="tooltip"]').tooltip({ trigger: 'hover' });

  $('input:file').on('change', function() {
    if ($(this).val()) {
      $('input:submit').attr('disabled', false);
    }
  });

  $('#assignLotModal').on('show.bs.modal', function(event) {
    const lot_name = $(event.relatedTarget).data('lot-name');
    $('#lot_name').text(lot_name);
    $('#assign_lot').data('lot_name', lot_name);

    const lot_id = $(event.relatedTarget).data('lot-id');
    $('#lot_id').val(lot_id);

    const project_id = $(event.relatedTarget).data('project-id');
    $('#project_id').val(project_id);

    const phase_id = $(event.relatedTarget).data('phase-id');
    $('#phase_id').val(phase_id);

    const stage_id = $(event.relatedTarget).data('stage-id');
    $('#stage_id').val(stage_id);
  });

  $(document).on('click', '.assignable', function() {
    const $this = $(this); // Polygon that triggered the modal
    const Toast = Swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
    });

    const lot_id = $('#lot_id').val(),
      project_id = $('#project_id').val(),
      phase_id = $('#phase_id').val(),
      stage_id = $('#stage_id').val(),
      blueprint_lot_id = $this.data('blueprint-lot-id'),
      blueprint_id = $this.data('blueprint-id');

    $.ajax({
      type: 'PUT',
      contentType: 'application/json',
      url: blueprint_lot_url(
        project_id,
        phase_id,
        stage_id,
        blueprint_id,
        blueprint_lot_id
      ),
      data: JSON.stringify({ blueprint_lot: { lot_id } }),
      success: blueprint => {
        $(`#lot-${lot_id}`).addClass('d-none');
        $this.addClass('assigned');
        $this.removeClass('assignable');
        $this.data('id', blueprint.id);
        $this.data('status', blueprint.lot.status);
        $this.attr(
          'data-original-title',
          `${blueprint.lot.name}<br>Estado: ${status_label(
            blueprint.lot.status
          )}`
        );
        $(`[data-id=${lot_id}]`)
          .find('.delete-button')
          .hide();
        $(`[data-id=${lot_id}]`)
          .find('.deallocate-button')
          .show();
        $(`[data-id=${lot_id}]`)
          .find('.assign-button')
          .hide();
        $('#assignLotModal').modal('hide');
        Toast.fire({
          type: 'success',
          title: `Lote ${blueprint.lot.name} asignado.`,
        });
      },
      error: error => {
        $('#assignLotModal').modal('hide');
        Toast.fire({
          type: 'warning',
          title: 'Hubo un error, por favor intentalo de nuevo.',
        });
      },
    });
  });
});
