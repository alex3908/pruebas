function defaultActions() {
  const email_reciever = $('#automated_email_reciever_type');
  const hidden_state = $('#automated_email_hidden_state');
  const execution_type = $('#automated_email_execution_type');

  if (email_reciever) {
    setDefaultFolderUser(email_reciever);
    email_reciever.on('change', function() {
      setDefaultFolderUser(email_reciever);
    });
  }

  if (hidden_state) {
    setStepAsOptional(hidden_state);
    hidden_state.on('change', function() {
      setStepAsOptional(hidden_state);
    });
  }

  if (execution_type) {
    execution_type.on('change', function() {
      disabledhiddenStates(execution_type);
    });
  }

  $('select:not(.not-select2)').each(function() {
    initSelect2(this);
  });
}

function setDefaultFolderUser(email_reciever) {
  if (email_reciever.val() == 'user') {
    $('#responsable').show();
    $('#folder_user').show();
    $('#client_user').hide();
    $('#automated_email_folder_user_concept_ids').prop('required', true);
    $('#automated_email_client_user_concept_ids').prop('required', false);
  } else if (email_reciever.val() == 'client_users') {
    $('#responsable').show();
    $('#folder_user').hide();
    $('#client_user').show();
    $('#automated_email_folder_user_concept_ids').prop('required', false);
    $('#automated_email_client_user_concept_ids').prop('required', true);
  } else {
    $('#responsable').hide();
    $('#folder_user').hide();
    $('#client_user').hide();
    $('#automated_email_folder_user_concept_ids').prop('required', false);
    $('#automated_email_client_user_concept_ids').prop('required', false);
  }
}

function setStepAsOptional(hidden_state) {
  if (hidden_state.val() == '') {
    $('#automated_email_step_id').prop('required', true);
    $('#automated_email_step_id').prop('disabled', false);
  } else {
    $('#automated_email_step_id')
      .val('')
      .trigger('change');
    $('#automated_email_step_id').prop('required', false);
    $('#automated_email_step_id').prop('disabled', true);
  }
}

function disabledhiddenStates(execution_type) {
  if (
    execution_type.val() === 'back_step' ||
    execution_type.val() === 'reject_step'
  ) {
    $('#automated_email_hidden_state')
      .val('')
      .trigger('change');
    $('#automated_email_hidden_state').prop('disabled', true);
  } else {
    $('#automated_email_hidden_state').prop('disabled', false);
  }
}
