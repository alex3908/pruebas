document.addEventListener('vue:mounted', () => {
  const is_automatic_input = $(
    "input[name^='digital_signature_service[is_automatic]'"
  );
  const jump_input = $("input[name^='digital_signature_service[jump_to_step]'");

  const is_shield_level_three_message_clients_input = $(
    "input[name^='digital_signature_service[is_shield_level_three_clients]'"
  );

  const is_shield_level_three_message_signers_input = $(
    "input[name^='digital_signature_service[is_shield_level_three_signers]'"
  );

  const input_area_step = $('#is_manual');
  const input_field_step = input_area_step.find('select');
  enabled(is_automatic_input, input_field_step);

  const input_area_jump = $('#is_jump');
  const input_field_jump = input_area_jump.find('select');
  enabled(jump_input, input_field_jump);

  const input_area_shield_level_three = $('#is_shield_level_three');
  const input_field_shield_level_three_message = input_area_shield_level_three.find(
    'textarea'
  );

  if (
    is_shield_level_three_message_clients_input.is(':checked') ||
    is_shield_level_three_message_signers_input.is(':checked')
  ) {
    input_field_shield_level_three_message
      .prop('disabled', false)
      .prop('required', true);
  } else {
    input_field_shield_level_three_message
      .prop('disabled', true)
      .prop('required', false);
  }

  is_automatic_input.change(function() {
    input_area_step.fadeToggle('slow');
    enabled(is_automatic_input, input_field_step);
  });

  jump_input.change(function() {
    input_area_jump.fadeToggle('slow');
    enabled(jump_input, input_field_jump);
  });

  is_shield_level_three_message_clients_input.change(function() {
    if (!is_shield_level_three_message_signers_input.is(':checked')) {
      input_area_shield_level_three.fadeToggle('slow');
      enabled(
        is_shield_level_three_message_clients_input,
        input_field_shield_level_three_message
      );
    }
  });

  is_shield_level_three_message_signers_input.change(function() {
    if (!is_shield_level_three_message_clients_input.is(':checked')) {
      input_area_shield_level_three.fadeToggle('slow');
      enabled(
        is_shield_level_three_message_signers_input,
        input_field_shield_level_three_message
      );
    }
  });
});

function enabled(checkbox, input) {
  if (checkbox.is(':checked')) {
    input.prop('disabled', false).prop('required', true);
  } else {
    input.prop('disabled', true).prop('required', false);
  }
}
